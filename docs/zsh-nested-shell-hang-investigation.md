# Nested zsh Shell Hang — Investigation & Mitigation

## Summary

Nested zsh shells (VS Code terminal, tmux panes, `zsh` inside ghostty, any `SHLVL > 1` context)
would hang after pressing Enter. The shell displayed a prompt but then froze — no output,
no response to input, Ctrl-C didn't help; only closing the window worked.

Two independent root causes were found:

1. **`starship prompt` reads from inherited stdin** — every starship subprocess
   (`PROMPT`, `RPROMPT`, `PROMPT2`, even `starship init zsh`) blocks when stdin is
   a pipe (as it is in VS Code shell integration, tmux, ghostty integration).
2. **`direnv export zsh` reads from stdin** — direnv's precmd hook has the same
   problem; `direnv export zsh` blocks on inherited pipe stdin.

---

## Timeline of the Issue

The issue existed at some level for a while but became consistently reproducible after
adding `jj-starship` (a Jujutsu VCS starship module) and enabling VS Code's shell
integration. The combination of multiple stdin-reading subprocesses triggered hangs in
all nested contexts.

---

## Debugging Method

### Step 1 — Isolate to `.zshrc`

Running `zsh -f` (no rc files) worked fine in nested shells. Sourcing files one by one
narrowed the hang to `~/.config/zsh/.zshrc`.

### Step 2 — Make `.zshrc` editable

The file is a symlink to the nix store (read-only). To edit it for testing:

```sh
cp ~/.config/zsh/.zshrc /tmp/zshrc-backup
rm ~/.config/zsh/.zshrc
cp /tmp/zshrc-backup ~/.config/zsh/.zshrc
chmod 644 ~/.config/zsh/.zshrc
```

Restore by running `darwin-rebuild switch` (home-manager recreates the symlink).

### Step 3 — Binary search

Commented out halves of `.zshrc` to narrow the culprit:

- First half active → no hang
- Second half active → hang
- First quarter of second half → no hang
- Added starship block → hang
- Disabled starship → no hang

**Starship confirmed as first culprit.**

### Step 4 — Isolate which part of starship hangs

`starship init zsh` sets up:
- `prompt_starship_precmd` (precmd hook — timing/job count, no subprocess)
- `prompt_starship_preexec` (preexec hook — timestamps, no subprocess)
- `zle-keymap-select` handler (calls `zle reset-prompt`)
- `PROMPT='$(starship prompt ...)'` (subprocess on every render)
- `RPROMPT='$(starship prompt --right ...)'` (subprocess on every render)
- `PROMPT2="$(starship prompt --continuation)"` (**synchronous** subprocess at startup)

Binary search through hooks:

| Test | Result |
|------|--------|
| All hooks removed + static `PROMPT='$ '` | No hang |
| `zle-keymap-select` active, precmd/preexec removed, static PROMPT | No hang |
| precmd active, preexec removed, static PROMPT | No hang |
| All hooks active, static PROMPT/RPROMPT | No hang (tmux) / Hang (VS Code) |
| All hooks active, real PROMPT/RPROMPT subprocess | Hang everywhere |
| `__sp() { starship prompt ... </dev/null }; PROMPT='$(__sp)'` | **No hang** |

**Finding: `starship prompt` reads from inherited stdin. Redirecting to `/dev/null` fixes it.**

VS Code hung even with static `PROMPT='$ '` because `PROMPT2` runs synchronously
inside `eval "$(starship init zsh)"` — it blocks at shell startup before any override
can take effect. Fix: pipe `starship init zsh` through `sed` to replace `PROMPT2` with
a static string before eval.

### Step 5 — Find remaining hang after starship fix

After fixing starship, VS Code and ghostty nested shells still hung. The test `.zshrc`
used during starship debugging had `direnv`, ghostty integration, and catppuccin
syntax-highlighting all commented out. Production rebuild re-enabled them.

Binary search on the three new additions:

| Test | Result |
|------|--------|
| direnv disabled, rest active | No hang |
| direnv enabled + `</dev/null` on hook | Hang (override not sufficient) |
| direnv enabled inline hook + `</dev/null` + `2>/dev/null` | Hang |
| direnv disabled permanently | **No hang** |

**Finding: `direnv export zsh` (called in `_direnv_hook` precmd) also reads from
inherited pipe stdin. The hang could not be mitigated with `/dev/null` redirect alone
(possibly `use_flake` in `.envrc` triggers nix operations that read stdin or use
other blocking FDs). Direnv zsh integration was disabled.**

---

## Root Cause — Why stdin is inherited and why it blocks

In a nested shell context:

- **VS Code**: Shell integration (`shellIntegration-rc.zsh`) sets up pipes between VS Code
  and the shell process for prompt tracking (OSC escape sequences). These pipes become
  the shell's stdin/stdout. Subprocesses inherit them.
- **tmux**: PTY multiplexing. Child processes inherit the PTY FD from tmux, which can
  block if the read buffer is full or the multiplexer is not draining.
- **ghostty integration**: `$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration`
  adds hooks and may redirect FDs.

When `starship prompt` or `direnv export zsh` inherits these FDs and internally does
a `read()` on stdin (for terminal capability detection, interactive prompts, or similar),
it blocks waiting for data that never comes — because no one is writing to that pipe.

The fix is `</dev/null` on any subprocess that doesn't need user input: redirecting
stdin to `/dev/null` makes `read()` return EOF immediately instead of blocking.

---

## Fixes Applied

### 1. Double `compinit` (fixed early)

**Problem:** `/etc/zshrc` (nix-darwin default) and `~/.config/zsh/.zshrc` (home-manager)
both called `compinit`. In nested shells, `fpath` grew unbounded (no dedup guard),
causing compinit signature mismatches and slow `.zcompdump` glob operations that hung.

**Fix in `modules/common/shell/default.nix`:**
```nix
programs.zsh = {
  enableGlobalCompInit = false;  # removes compinit from /etc/zshrc
  enableBashCompletion = false;
};
```

**Fix in `modules/home/core/shell/default.nix`:**
```nix
programs.zsh.envExtra = ''
  typeset -U path PATH fpath FPATH manpath MANPATH cdpath CDPATH
'';
programs.zsh.completionInit = ''
  autoload -U compinit
  compinit -C -d "$ZDOTDIR/.zcompdump"  # -C skips security check, uses cache
'';
```

### 2. `jj-starship` stdin hang

**Problem:** Custom starship module for Jujutsu VCS called `jj-starship` which read
from stdin, blocking in nested shells.

**Fix in `modules/home/core/shell/starship/starship.toml`:**
```toml
[custom.jj]
command = "jj-starship < /dev/null"
detect_folders = [".jj"]
shell = ["sh"]
format = "$output "
```

### 3. `starship prompt` subprocess stdin hang

**Problem:** `PROMPT` and `RPROMPT` evaluate `$(starship prompt ...)` on every render.
`starship init zsh` evaluates `PROMPT2="$(starship prompt --continuation)"` synchronously
at shell startup. All block on inherited pipe stdin.

**Fix in `modules/home/core/shell/starship/default.nix`:**

```nix
programs.starship = {
  enable = true;
  enableZshIntegration = false;  # disable auto eval — we do it manually below
  settings = lib.importTOML ./starship.toml;
};

programs.zsh.initContent = lib.mkOrder 2000 ''
  if [[ $TERM != "dumb" ]]; then
    # sed patches out PROMPT2 before eval — it would run $(starship prompt --continuation)
    # synchronously at startup, hanging in nested shells.
    eval "$(starship init zsh </dev/null | sed 's/PROMPT2=.*/PROMPT2="> "/')"

    # PROMPT/RPROMPT wrappers redirect stdin to /dev/null — starship reads stdin
    # and blocks in nested shells (VS Code, tmux, ghostty) where stdin is a pipe.
    __starship_prompt() {
      starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" \
        --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
        --cmd-duration="${STARSHIP_DURATION:-}" --jobs="${STARSHIP_JOBS_COUNT:-}" \
        </dev/null
    }
    __starship_rprompt() {
      starship prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" \
        --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
        --cmd-duration="${STARSHIP_DURATION:-}" --jobs="${STARSHIP_JOBS_COUNT:-}" \
        </dev/null
    }
    PROMPT='$(__starship_prompt)'
    RPROMPT='$(__starship_rprompt)'
  fi
'';
```

`lib.mkOrder 2000` is required — home-manager's starship module (with `enableZshIntegration`)
uses no explicit mkOrder (defaults to 1000), so our block at 2000 runs after it.
Since we set `enableZshIntegration = false`, the auto-eval never runs; we own it entirely.

### 4. `direnv export zsh` stdin hang

**Problem:** `_direnv_hook` (added to `precmd_functions` by `direnv hook zsh`) calls
`direnv export zsh` on every prompt. This subprocess (or something it triggers, likely
`use_flake` → nix) blocks on inherited pipe stdin. Redirecting with `</dev/null` was
not sufficient — the hang persisted, possibly due to nix daemon communication or
other blocking FDs inherited beyond stdin.

**Fix in `modules/home/core/pkgs/direnv/default.nix`:**
```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
  enableBashIntegration = true;
  enableFishIntegration = true;
  enableZshIntegration = false;  # disabled — hangs in nested shells
};
```

**Impact:** `direnv` binary is still installed and available. `.envrc` files are still
loaded when you explicitly run `direnv allow` / `direnv exec`. The automatic
per-prompt environment update is disabled in zsh only. Fish shell integration still works.

---

## What Is Currently Disabled / Hacked

| Item | Status | Reason |
|------|--------|--------|
| `direnv` zsh auto-hook | **Disabled** | `direnv export zsh` hangs in nested shells |
| `PROMPT2` starship subprocess | **Replaced** with static `'> '` | Runs synchronously at startup, blocks on pipe stdin |
| `starship init zsh` auto-integration | **Replaced** with manual eval + sed | Need to control PROMPT2 and add `</dev/null` to init subprocess |
| `jj-starship` stdin | **Redirected** `< /dev/null` | Binary reads stdin |

---

## What Still Works

- Full starship prompt (colors, git status, jj status, all modules) in all terminals
- `jj-starship` module (with stdin redirect)
- direnv in fish shell
- direnv CLI (`direnv allow`, `direnv exec`, manual `eval "$(direnv export zsh)"`)
- All other zsh functionality (zsh-vi-mode, autosuggestions, fzf, syntax highlighting,
  catppuccin theme, ghostty integration, tmux)

---

## How to Check If Hacks Can Be Removed

### Test if starship fixed its stdin reading

Run in a nested shell (open VS Code terminal or `zsh` inside ghostty):

```sh
# Should complete instantly, not hang
timeout 3 starship prompt --terminal-width=80 </dev/null && echo "OK: no stdin read"
timeout 3 starship prompt --continuation </dev/null && echo "OK: PROMPT2 safe"
timeout 3 starship init zsh </dev/null >/dev/null && echo "OK: init safe"
```

If all three print "OK", the `/dev/null` redirects in the nix config are still needed
but `starship init zsh` without redirect might now be safe. Test by temporarily removing
the `</dev/null` from the eval line and the sed PROMPT2 patch.

Check starship changelog for: "fix stdin reading", "non-blocking stdin", or "tty detection".
Starship version in use: **1.24.2**. Monitor releases at https://github.com/starship/starship/releases

### Test if direnv fixed its stdin reading

Run in a nested shell:

```sh
# Should complete in <1s if direnv doesn't block
timeout 3 direnv export zsh </dev/null && echo "OK: direnv no stdin block"
```

If it completes, test re-enabling:

```sh
# Temporarily in shell:
eval "$(direnv hook zsh </dev/null)"
_direnv_hook() {
  trap -- '' SIGINT
  eval "$(direnv export zsh </dev/null 2>/dev/null)"
  trap - SIGINT
}
# Then press Enter several times in a nix project dir with .envrc
```

If no hang, change `enableZshIntegration = false` back to `true` in
`modules/home/core/pkgs/direnv/default.nix` and remove the manual hook override.

Check direnv changelog for: "stdin handling", "tty detection", "nested shell".
direnv version in use: **2.37.1**.

### Identify if the real issue is nix-direnv `use_flake`

The hang might be specifically from `use_flake` (nix-direnv) rather than direnv itself.
Test in a shell with a nix flake `.envrc` vs a simple `.envrc` (e.g., just `export FOO=bar`):

```sh
# In a dir with simple .envrc
echo 'export FOO=test' > /tmp/test-direnv/.envrc
cd /tmp/test-direnv && direnv allow
# Open nested shell here — does _direnv_hook hang?
```

If simple `.envrc` works but flake doesn't, the issue is nix-direnv specifically,
not direnv. In that case, you could re-enable direnv zsh integration and disable
nix-direnv, or find a nix-direnv workaround.

---

## Architecture Note — Why mkOrder 2000

Home-manager's module system concatenates `programs.zsh.initContent` values in
ascending mkOrder. Observed ordering in generated `.zshrc`:

| Source | mkOrder | Content |
|--------|---------|---------|
| home-manager base zsh | ~100 | compinit, plugins, history |
| our shell module | 1000 | zvm_after_init, nvm lazy-load |
| starship module (auto) | ~1000 | `eval "$(starship init zsh)"` |
| our starship override | **2000** | manual eval + PROMPT wrappers |

The override MUST be at a higher number than the auto-integration to run after it.
Since we disabled `enableZshIntegration`, the auto eval line no longer appears —
but keeping `mkOrder 2000` is safe and future-proof.

---

## Files Changed

```
modules/common/shell/default.nix          — enableGlobalCompInit = false
modules/home/core/shell/default.nix       — compinit -C, typeset -U, zvm_after_init
modules/home/core/shell/starship/default.nix  — manual starship init, PROMPT wrappers
modules/home/core/shell/starship/starship.toml — jj-starship < /dev/null
modules/home/core/pkgs/direnv/default.nix — enableZshIntegration = false
```
