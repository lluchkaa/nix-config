# nix-config

This configuration repository is inspired by [Mitchell Hashimoto NixOS config](https://github.com/mitchellh/nixos-config)

## TODO:
- [ ] Rewrite Neovim config

## Tool selections

The existing `lluchkaa` account owns its tool and package selections in
`users/lluchkaa/home.nix`. Enable or disable tools there:

```nix
# users/lluchkaa/home.nix
programs.neovim.enable = true;
programs.claude-code.enable = false;
programs.git.settings.pull.rebase = false;
workstation.node.enable = true;     # Node.js 26 and pnpm
workstation.copilot.enable = false;
```

Shared settings live under `modules/home/`. They are applied only when the
corresponding tool is enabled and use defaults that a user can override. Native
Home Manager switches are used where available; Node and Copilot have
`workstation.<tool>.enable` switches. Extra packages are listed directly in each
user's `home.packages`. Disabling tmux also removes its sessionizer, alias, and
gitmux files/package; disabling Neovim removes its configuration and extra tools.

Homebrew selections live alongside the user configuration:

| File under `users/lluchkaa/homebrew/` | Selection |
| --- | --- |
| `brews/default.nix` | Formulae |
| `casks/default.nix` | GUI applications |
| `mas/default.nix` | Mac App Store application IDs |

[nix-homebrew](https://github.com/zhaofengli/nix-homebrew) now bootstraps Homebrew
on activation and adopts an existing installation through `autoMigrate`. The
`lluchkaa` account owns the standard prefix and runs the Homebrew bundle.
MAS installation uses that account's App Store session.

The Darwin target remains `macbook-pro-m1`, managing the existing `lluchkaa`
account. Git and Jujutsu keep the personal author identity; Git uses
`user.useConfigOnly` to refuse an inferred identity.

Validate the configuration and tool checks with `nix flake check path:.`.
