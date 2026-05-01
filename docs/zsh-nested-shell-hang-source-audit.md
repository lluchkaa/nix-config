# Nested zsh Shell Hang — Source-Code Audit & Test Plan

Companion to [zsh-nested-shell-hang-investigation.md](./zsh-nested-shell-hang-investigation.md).
Investigation doc described **symptoms** and **empirical fixes**. This doc records
**source-code findings** from cloning starship and direnv upstream, and lays out
a test plan to (a) try a supported direnv config flag and (b) pin down what
actually causes the starship hang.

Repos cloned at `~/projects/shell-tools/{starship,direnv}` for the audit.

| Tool | Installed | Latest |
|------|-----------|--------|
| starship | 1.24.2 | 1.25.1 (2026-04-30) |
| direnv | 2.37.1 | 2.37.1 |

---

## 1. Starship — No `read(stdin)` in the prompt path

The investigation doc claims:

> Finding: `starship prompt` reads from inherited stdin. Redirecting to `/dev/null` fixes it.

**Source audit does not confirm this claim.** Empirically the `</dev/null` redirect
works, but the cause is likely indirect (child process, FD inheritance,
shell-side behavior) rather than a `read()` in the starship binary.

### Files audited

- `~/projects/shell-tools/starship/src/print.rs`
- `~/projects/shell-tools/starship/src/utils/mod.rs`
- `~/projects/shell-tools/starship/src/modules/custom.rs`
- `~/projects/shell-tools/starship/src/init/starship.zsh`

### Stdin reads in starship source

```
$ grep -rn 'io::stdin\|stdin()' src/
src/bug_report.rs:39:    let _ = std::io::stdin().read_line(&mut input);
src/print.rs:81:    let claude_data = serde_json::from_reader(io::stdin())
src/print.rs:82:        .inspect_err(|e| log::error!("Failed to read Claude Code JSON from stdin: {e}"))
```

Only two real reads in source:

| File:line | Function | Invoked from PROMPT? |
|-----------|----------|----------------------|
| `src/bug_report.rs:39` | bug-report flow | No (manual `starship bug-report`) |
| `src/print.rs:81-82` | `prompt_with_claude_code()` | No (statusline subcmd, new in 1.25.0) |

The hot-path `pub fn prompt(args, target)` at `src/print.rs:72-78` only writes
stdout:

```rust
pub fn prompt(args: Properties, target: Target) {
    let context = Context::new(args, target);
    let stdout = io::stdout();
    let mut handle = stdout.lock();
    write!(handle, "{}", get_prompt(&context)).unwrap();
}
```

### Subprocesses spawned by starship

| File:line | Stdin handling |
|-----------|----------------|
| `src/utils/mod.rs:121-123` `create_command()` | `.stdin(Stdio::null())` — child gets `/dev/null` |
| `src/modules/git_state.rs:262` | `.stdin(Stdio::null())` |
| `src/modules/git_metrics.rs:817` | `.stdin(Stdio::null())` |
| `src/modules/custom.rs:183` | `.stdin(Stdio::piped())` — pipe owned by parent, written once at line 204 then no further read |
| `src/configure.rs:279` | `.stdin(Stdio::inherit())` — `starship configure --edit` editor invocation; only used interactively |

So the starship binary itself sets stdin safely on every child it spawns in
the prompt-render path. The `Stdio::piped()` case in custom modules is also
safe: parent writes the script, child reads it; no parent-stdin inheritance.

### What custom modules execute

In `src/modules/custom.rs:152-225` `shell_command()`:

```rust
command
    .current_dir(&context.current_dir)
    .args(shell_args)
    .stdin(Stdio::piped())
    .stdout(Stdio::piped())
    .stderr(Stdio::piped());
...
if use_stdin {
    child.stdin.as_mut()?.write_all(cmd.as_bytes()).ok()?;
}
```

The shell child (e.g. `sh`, `bash`) is passed the user's command via stdin.
After `write_all`, the parent drops its end. **However, the user's command
itself can spawn further children** (e.g. `jj-starship`) which inherit the
parent shell's FDs. If the user's `[custom.jj]` config invokes a binary that
itself calls `read(0)`, *that* binary blocks. That matches the symptom and is
exactly why `command = "jj-starship < /dev/null"` works — it shifts FD 0 of the
inner binary to `/dev/null`.

### Init script — PROMPT2 synchronous subprocess

`src/init/starship.zsh:102` (last line):

```zsh
PROMPT2="$(::STARSHIP:: prompt --continuation)"
```

Runs at `eval "$(starship init zsh)"` time. Synchronous. Blocks the shell at
startup if any inherited FD trips up the subprocess. This is what the
investigation doc fixes via `sed 's/PROMPT2=.*/PROMPT2="> "/'`. Worth a
direct test under the new starship version (Test 2c below).

### Conclusion for starship

The hacks in `modules/home/core/shell/starship/default.nix` are **empirically
required** but their stated mechanism is not supported by the source. Real
mechanism is most likely one of:

- A custom module's external binary (jj-starship analogue) inheriting FDs.
- A library/dependency call doing its own FD probe (`isatty` on a non-stdin
  FD that's a stuck pipe, or similar).
- Zsh-side interaction between `$(...)` command-substitution and VS Code's
  shell-integration FD setup, where `</dev/null` happens to break a deadlock
  unrelated to starship.

No GitHub issue matches the symptom verbatim. Closest:

- starship/starship#5816 — "starship init bash in vscode: integrated terminal
  crashes due to infinite loop" — different (PROMPT_COMMAND interaction).
- starship/starship#6214 — "VSCode shell integration breaks with fish if
  starship is enabled" — closed, fish-specific.

---

## 2. Direnv — `disable_stdin` config IS the supported fix

`internal/cmd/rc.go:246-255`:

```go
// Set stdin based on the config
var stdin *os.File
if config.DisableStdin {
    stdin, err = os.Open(os.DevNull)
    if err != nil {
        return
    }
} else {
    stdin = os.Stdin
}
```

Then `internal/cmd/rc.go:279`:

```go
cmd.Stdin = stdin
```

Where `cmd` is the bash subprocess that evaluates `.envrc` (incl. `use_flake`,
`use_nix`, dotenv). Source: `internal/cmd/rc.go:264-279`.

`config.DisableStdin` is set from `~/.config/direnv/direnv.toml`
(`internal/cmd/config.go:57` = `tomlGlobal.DisableStdin`,
`config.go:193` = `config.DisableStdin = tomlConf.DisableStdin`).

Documented at `man/direnv.toml.1.md:41-43`:

> ### `disable_stdin`
> If set to `true`, stdin is disabled (redirected to /dev/null) during the
> `.envrc` evaluation.

### All stdin reads in direnv

```
$ grep -rn 'os.Stdin' internal/ pkg/ main.go
internal/cmd/rc.go:254:		stdin = os.Stdin       # gated by DisableStdin
internal/cmd/cmd_edit.go:65:	cmd.Stdin = os.Stdin   # `direnv edit`, interactive only
internal/cmd/cmd_watch_list.go:47:	reader := bufio.NewReader(os.Stdin)  # `direnv watch-list`, manual
```

Only one path (`rc.go:254`) is on the auto-hook code path. Toggling the toml
flag should fully remove the inherited-stdin route.

### Why the investigation doc's `</dev/null` workaround "didn't work"

The doc reports:

> direnv enabled inline hook + `</dev/null` + `2>/dev/null` | Hang

`</dev/null` was applied to the **outer** invocation:

```sh
eval "$(direnv export zsh </dev/null 2>/dev/null)"
```

That sets the **direnv binary's** FD0 to `/dev/null`. Inside direnv, the bash
subprocess gets `cmd.Stdin = os.Stdin`, which IS `/dev/null` at that point —
so on paper this should have worked. Possible reasons it didn't:

1. The hook function was overridden after direnv re-installed itself on a
   later precmd, and the override was lost (precmd ordering).
2. The hang was not actually direnv's bash child — it was nix-daemon FD or
   something deeper. `disable_stdin` won't fix that either, but it's still the
   first thing to try because it is the supported flag.
3. Test methodology drift — the override was sourced into a shell that
   already had the original hook installed, so the original kept running.

`disable_stdin = true` is unambiguous: it lives in direnv.toml, persists across
restarts, and is read every invocation. Worth retesting.

### Empirical result on this machine

Setting `programs.direnv.config.global.disable_stdin = true` (which generates
`~/.config/direnv/direnv.toml` with `[global]\ndisable_stdin = true`) and
re-enabling `enableZshIntegration = true` **did not** stop the hang on this
machine.

That makes outcome (2) above — "the hang is not in direnv's bash subprocess,
it's deeper" — the most likely. Next step is **Test 1b** below: a direct
syscall-level capture (`dtruss`/`sample`) on the actually-stuck process to
identify what FD or daemon socket is blocked.

For now, `enableZshIntegration = false` stays.

### GitHub references

- direnv/direnv#1430 — "Direnv breaks Visual Studio Code terminal output
  capture" — different bug (output capture, not hang).
- direnv/direnv#755 — "Direnv hangs when a subprocess doesn't exit" — open
  but encfs-specific.
- No existing issue matches the nested-shell + flake hang verbatim.

---

## 3. Recommended changes (already trialled)

### 3.1 Direnv (REVERTED — fix did not hold)

Trialled `programs.direnv.config.global.disable_stdin = true` plus
`enableZshIntegration = true`. Hang persisted in nested contexts. Reverted to
`enableZshIntegration = false`.

`disable_stdin = true` in direnv.toml is still a valid config to keep around
once Test 1b identifies the real blocker. Do not re-apply blindly.

### 3.2 Starship — keep hacks until Test 2 yields a cause

Do not remove `</dev/null` redirects, the sed PROMPT2 patch, or the manual
init eval. Source audit found no in-binary `read()`, so we don't yet know
*what* the redirect actually fixes — removing it is too risky.

Worth doing soon: **bump starship 1.24.2 → 1.25.1** for unrelated bug fixes
(bare-repo detect #7421, python schema #7415, jobs counting #46ab862,
ERR_EXIT zero-duration #38db5f0). No stdin/hang fix in changelog.

---

## 4. Test plan

### Test 1 — Direnv with `disable_stdin`

Already trialled — hang persisted. Skip the toml-only retry.

#### Test 1b — Identify the actual blocker

In a hung nested shell (after `cd` into a flake `.envrc` dir):

```sh
# From a *different* shell, sample the stuck subprocess of direnv:
ps -ef | rg 'direnv|nix-instantiate|bash.*direnv' | rg -v rg
# Pick the leaf-most pid (deepest child), then:
sample <pid> 5 -file /tmp/direnv-stuck.txt
# And on macOS:
sudo dtruss -p <pid> 2>&1 | head -100
```

Look for:
- `read(0, ...)` → still stdin somewhere (toml flag didn't reach).
- `read(<N>, ...)` with N > 2 → inherited pipe FD beyond stdin (VS Code's
  shell-integration pipes).
- `recvfrom`/`recv`/`connect` → nix-daemon socket waiting on something.
- `kevent`/`select` on a specific FD → multiplexed wait, identify the FD.

Capture and append findings here.

### Test 2 — Starship hack-cause identification

#### 2a. Strip starship.toml customs and retest

```sh
cp ~/.config/starship.toml /tmp/starship.toml.bak
cat > /tmp/starship-min.toml <<'EOF'
add_newline = false
[character]
success_symbol = "[\\$](bold green)"
EOF
STARSHIP_CONFIG=/tmp/starship-min.toml zsh
# Open VS Code terminal / nested ghostty zsh and test for hang
```

If no hang → bisect `~/.config/starship.toml`'s custom modules until hang
returns. The reintroduced module is the culprit.

If hang persists with minimal toml → not custom modules. Move to 2b.

#### 2b. Strace/dtruss the prompt subprocess

```sh
# In a fresh nested shell, define a naked PROMPT wrapper without </dev/null:
__sp_naked() {
    starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" \
        --status="${STARSHIP_CMD_STATUS:-0}" \
        --pipestatus="${STARSHIP_PIPE_STATUS[*]:-0}" \
        --cmd-duration="${STARSHIP_DURATION:-0}" \
        --jobs="${STARSHIP_JOBS_COUNT:-0}"
}
PROMPT_OLD="$PROMPT"; PROMPT='$(__sp_naked)'
# Press Enter — when it hangs, in a *different* shell:
pgrep -f 'starship prompt' | head
sample <pid> 5 -file /tmp/starship-stuck.txt
sudo dtruss -p <pid> 2>&1 | head -50
```

Same FD analysis as Test 1b.

#### 2c. Test PROMPT2 in isolation

```sh
# In a nested shell that reproduces the hang:
time starship prompt --continuation
time starship prompt --continuation </dev/null
```

If timings differ wildly, PROMPT2 init really does need the redirect. If
identical, the sed patch in `modules/home/core/shell/starship/default.nix`
may be removable.

#### 2d. Bump starship to 1.25.1 and rerun 2a–2c

If 1.25.1 fixes anything silently (via dependency bumps), the hacks may be
removable without needing a root-cause.

### Test 3 — Trial removal of starship hacks (only after Test 2)

In `modules/home/core/shell/starship/default.nix`, remove one element at a
time, rebuild, retest in plain ghostty + nested ghostty zsh + VS Code + tmux:

| Step | Change | Pass criteria |
|------|--------|---------------|
| 3.1 | Drop `</dev/null` from `__starship_prompt` | No hang on Enter |
| 3.2 | Drop `</dev/null` from `__starship_rprompt` | No hang on Enter |
| 3.3 | Drop `sed 's/PROMPT2=.*/.../' ` patch | Shell start < 1s nested |
| 3.4 | Drop `</dev/null` from `starship init zsh` | Shell start < 1s nested |
| 3.5 | `enableZshIntegration = true`, drop manual `lib.mkOrder 2000` block | Shell starts and renders normally |

Stop at first regression — prior step still required.

### Test 4 — `jj-starship` redirect

```sh
cd <a jj repo>
time jj-starship              # inherited stdin
time jj-starship </dev/null   # redirected
```

Identical timings → redirect is now no-op, removable from
`modules/home/core/shell/starship/starship.toml`'s `[custom.jj] command`.

---

## 5. References

### Starship source (1.25.1, `~/projects/shell-tools/starship`)

- `src/print.rs:72-78` — `prompt()`, no stdin read
- `src/print.rs:80-91` — `prompt_with_claude_code()`, only stdin reader in
  prompt namespace, not invoked from PROMPT/RPROMPT
- `src/utils/mod.rs:104-126` — `create_command()` sets `Stdio::null()` on
  child stdin
- `src/modules/custom.rs:150-225` — custom-module shell invocation
- `src/init/starship.zsh:1-102` — full zsh init script, `PROMPT2` at line
  102 is the synchronous subprocess

### Direnv source (2.37.1, `~/projects/shell-tools/direnv`)

- `internal/cmd/rc.go:246-279` — `Load()` stdin handling (`DisableStdin` gate)
- `internal/cmd/config.go:28,57,193` — `DisableStdin` field, toml binding
- `internal/cmd/shell_zsh.go:9-24` — `_direnv_hook` template installed by
  `direnv hook zsh`
- `man/direnv.toml.1.md:41-43` — `disable_stdin` documentation

### Nix-config files involved

- `modules/home/core/pkgs/direnv/default.nix` — direnv home-manager module
- `modules/home/core/shell/starship/default.nix` — starship module + manual
  init eval + PROMPT/RPROMPT wrappers
- `modules/home/core/shell/starship/starship.toml` — starship config
- `modules/common/shell/default.nix` — `enableGlobalCompInit = false`
- `modules/home/core/shell/default.nix` — `compinit -C`, `typeset -U`

### GitHub issues / PRs reviewed (no exact match)

- starship/starship#5816 (open) — vscode bash infinite loop, different cause
- starship/starship#6214 (closed) — vscode fish + starship, fixed
- starship/starship#7132 (closed) — direnv module unknown state in Ghostty
- starship/starship#6524 (open) — zsh vi-mode + right-prompt
- direnv/direnv#1430 (open) — vscode terminal output capture, not hang
- direnv/direnv#755 (open) — direnv hangs on subprocess (encfs-specific)
- direnv/direnv#1237 (open) — fish-specific stdin issue
