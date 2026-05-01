# Starship & Direnv — Bug Audit

Audit of cloned source trees at:
- `~/projects/shell-tools/starship` (v1.25.1, released 2026-04-30)
- `~/projects/shell-tools/direnv`  (v2.37.1, released 2025-07-20)

Installed versions at audit time: starship **1.24.2**, direnv **2.37.1**.

---

## Starship Bugs

### 1. `wrap_colorseq_for_shell` — CSI/OSC sequences corrupt ZLE cursor position

**File:** `src/utils/mod.rs:585–626`
**Issue:** https://github.com/starship/starship/issues/7435
**PR (open, not yet merged):** https://github.com/starship/starship/pull/7436

**Root cause:**

`wrap_colorseq_for_shell` wraps ANSI escape sequences in shell markers (`%{…%}` for
zsh, `\[…\]` for bash) so the shell's line editor can compute prompt display width
correctly. The old implementation uses a single boolean `escaped` and only recognises
`\x1b` (ESC) as begin and `m` as end:

```rust
// src/utils/mod.rs:610–624 (current broken code)
let mut escaped = false;
let final_string: String = ansi.chars().map(|x| {
    if x == escape_begin && !escaped {
        escaped = true;
        format!("{beg}{escape_begin}")
    } else if x == escape_end && escaped {   // escape_end == 'm'
        escaped = false;
        format!("{escape_end}{end}")
    } else {
        x.to_string()  // all other chars pass through unchanged
    }
}).collect();
```

This only handles SGR sequences (`\x1b[…m`). Any other CSI sequence (e.g. `\x1b[K`
erase-line, `\x1b[H` cursor-position, `\x1b[?25l` hide-cursor) ends with a non-`m`
final byte. When such a sequence appears:

1. `\x1b` → `escaped = true`, emits `%{\x1b`
2. Subsequent chars pass through (condition 3)
3. Final byte (e.g. `K`) is NOT `m` → `escaped` stays `true` permanently

Now every `m` character in subsequent **normal text** triggers condition 2, emitting
`m%}`. ZLE uses `%{…%}` to mark zero-width (invisible) content. Wrong markers make ZLE
miscalculate the prompt's display width → cursor lands at wrong column → ZLE thinks
it is inside the prompt area → **pressing Enter moves to next line instead of
executing the command** (terminal appears stuck, accepting input but not running it).

Same mechanism affects bash (`\[…\]` markers).

**PR #7436 status:** Fixes CSI sequences by replacing the boolean with a loop that
consumes the full CSI sequence. The PR reviewer (maintainer `davidkna`) requested two
more changes before merge:

1. Also handle **OSC sequences** (`\x1b]…BEL` or `\x1b]…ST`) — e.g. terminal title
   (`\x1b]0;…\x07`), hyperlinks (`\x1b]8;…\x1b\`). The PR's current inner loop exits
   on `]` (0x5D is in the `@`–`~` final-byte range), so OSC sequences are still broken.
2. Use a **proper state machine** instead of nested loops.

**Workaround in this config:**
`modules/home/core/shell/starship/default.nix` — prompt wrappers redirect stdin to
`/dev/null`, which does not fix this bug but was applied for the separate stdin-hang
issue. The cursor corruption from this bug may still occur if any non-SGR ANSI sequence
appears in prompt output (e.g. from a custom module or user-supplied format string with
`\x1b[K` powerline bleed workaround). Track PR #7436 for upstream fix.

---

### 2. `git_status` staged count misses deletions and renames

**File:** `src/modules/git_status.rs:478–496` (gitoxide path) and `:695` (fallback path)
**Issue:** https://github.com/starship/starship/issues/7424

**Root cause — gitoxide path (src/modules/git_status.rs:468–497):**

```rust
match change {
    Change::Addition { .. } => {
        repo_status.staged += 1;      // ✓ counted
        repo_status.index_added += 1;
    }
    Change::Deletion { .. } => {
        repo_status.deleted += 1;     // ✗ staged++ missing
        repo_status.index_deleted += 1;
    }
    Change::Modification { .. } => {
        repo_status.staged += 1;      // ✓ counted
        // …
    }
    Change::Rewrite { .. } => {
        repo_status.renamed += 1;     // ✗ staged++ missing
    }
}
```

**Root cause — git porcelain fallback (src/modules/git_status.rs:695):**

```rust
self.staged = self.index_modified + self.index_added + self.index_typechanged;
// missing: + self.index_deleted  (staged deletes)
// missing: staged renames (parsed separately in `add()` at line 703)
```

**Effect:** `git rm file` (staged delete) or `git mv a b` (staged rename) do not
increment the `staged` counter. The `$staged` variable in the prompt format remains 0
even when staged deletions/renames exist.

---

### 3. Maven `detect_folders` matches `~/.mvn` user settings directory

**File:** `src/configs/maven.rs:35`
**Issue:** https://github.com/starship/starship/issues/7418

**Root cause:**

```rust
// src/configs/maven.rs:32–35
detect_files: vec!["pom.xml"],
detect_folders: vec![".mvn"],   // ← too broad
```

Maven stores **per-user** configuration in `~/.mvn/` (`~/.mvn/maven.config`,
`~/.mvn/jvm.config`, etc.). This is a valid user-level settings directory, not a
project marker. The scanner checks whether the current directory contains a `.mvn`
subdirectory. When `$HOME` is the current directory (or any ancestor during recursive
scan), `~/.mvn/` triggers the module.

The documented detection criteria (https://starship.rs/config/#maven) are:
- `pom.xml` present, OR
- `.mvn/wrapper/maven-wrapper.properties` present

Fix: remove `.mvn` from `detect_folders`; add `".mvn/wrapper/maven-wrapper.properties"`
to `detect_files` instead.

---

### 4. `wrap_colorseq_for_shell` — tests encode broken behaviour

**File:** `src/utils/mod.rs:977–1013`

The existing tests for `wrap_seq_for_shell` assert on the **buggy output**. For example:

```rust
let test1 = "\x1b]330;mlol\x1b]0m";
// \x1b] starts an OSC sequence; 'm' here is payload data, not an SGR terminator.
// Broken code treats 'm' as end-of-sequence and produces:
assert_eq!(&zresult1, "%{\x1b]330;m%}lol%{\x1b]0m%}");
// This is wrong: the OSC content between ] and m is wrapped as if it were SGR.
```

These tests will need updating alongside any fix to `wrap_colorseq_for_shell`.

---

## Direnv Bugs

### 5. `logError` / `logStatus` — ANSI color logic is inverted

**File:** `internal/cmd/log.go:28–49`
**Issue:** https://github.com/direnv/direnv/issues/1551

**Root cause:**

```go
// log.go:28–35
func logError(c *Config, msg string, a ...interface{}) {
    if c.LogColor {
        logMsg(defaultLogFormat, msg, a...)                          // no color
    } else {
        logMsg(errorColor+defaultLogFormat+clearColor, msg, a...)   // ANSI color!
    }
}

// log.go:37–49
func logStatus(c *Config, msg string, a ...interface{}) {
    // …
    if shouldLog && format != "" {
        if c.LogColor {
            logMsg(format, msg, a...)                                // no color
        } else {
            logMsg(fmt.Sprintf("%s%s", clearColor, format), msg, a...) // ANSI escape!
        }
    }
}
```

`config.go:153` sets `config.LogColor = os.Getenv("TERM") != "dumb"`.

When `TERM=dumb`, `LogColor = false` → `else` branch runs → ANSI escape codes sent to
a terminal that cannot render them. Produces garbled output like `^[[0mdirenv: loading
~/.envrc` on dumb terminals. The `if` and `else` branches are swapped in both functions.

**Status:** Not fixed in this config. Low impact since we are not on dumb terminals, but
the upstream bug is open and unfixed.

---

### 6. `rc.go` — `.envrc` subprocess inherits interactive stdin by default

**File:** `internal/cmd/rc.go:246–255`
**Related issues:** https://github.com/direnv/direnv/issues/1520
                   https://github.com/direnv/direnv/issues/1529
                   https://github.com/direnv/direnv/issues/1548

**Root cause:**

```go
// rc.go:246–255
var stdin *os.File
if config.DisableStdin {
    stdin, err = os.Open(os.DevNull)
} else {
    stdin = os.Stdin   // ← default: .envrc subprocess inherits interactive stdin
}
cmd.Stdin = stdin
```

Default `disable_stdin = false` passes the live terminal stdin to the bash subprocess
that evaluates `.envrc`. Any command inside `.envrc` that reads stdin (interactively or
accidentally) will consume terminal input with no visible prompt. Specific triggers:

- `use_flake` → calls `nix print-dev-env --profile …` (stdlib.sh:1355) — nix may
  prompt for input or block on pipe FDs
- `use python` with venv tools that prompt interactively
- Any custom function calling `read` or an interactive installer

**Effect:** After entering a directory with an `.envrc`, the terminal appears stuck —
characters are accepted (stdin consumed by the subprocess) but nothing executes.

**Fix applied in this config:**

`modules/home/core/pkgs/direnv/default.nix`:
```nix
config.global.disable_stdin = true;
```

This writes `disable_stdin = true` to `~/.config/direnv/direnv.toml` under `[global]`.
The bash subprocess evaluating `.envrc` now receives `/dev/null` as stdin. Interactive
`.envrc` commands that genuinely need user input must explicitly reopen the terminal:
```bash
exec 0</dev/tty some-interactive-command
```

---

## Summary Table

| # | Tool | File | Issue | Severity | Fixed here |
|---|------|------|-------|----------|------------|
| 1 | starship | `src/utils/mod.rs:585` | [#7435](https://github.com/starship/starship/issues/7435) | High — stuck terminal (cursor corruption) | No — track [PR #7436](https://github.com/starship/starship/pull/7436) |
| 2 | starship | `src/modules/git_status.rs:478,695` | [#7424](https://github.com/starship/starship/issues/7424) | Medium — staged count wrong for deletes/renames | No |
| 3 | starship | `src/configs/maven.rs:35` | [#7418](https://github.com/starship/starship/issues/7418) | Low — maven shown in home dir | No |
| 4 | starship | `src/utils/mod.rs:977` | — | Low — tests assert broken output | No |
| 5 | direnv | `internal/cmd/log.go:28` | [#1551](https://github.com/direnv/direnv/issues/1551) | Low — ANSI on dumb terminals | No |
| 6 | direnv | `internal/cmd/rc.go:246` | [#1520](https://github.com/direnv/direnv/issues/1520) | High — stuck terminal (stdin block) | **Yes** — `disable_stdin = true` |
