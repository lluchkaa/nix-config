# nix-config

This configuration repository is inspired by [Mitchell Hashimoto NixOS config](https://github.com/mitchellh/nixos-config)

## TODO:
- [ ] Rewrite Neovim config

## Personal and work profiles

Each account owns its selections in `users/<username>/home.nix`. Both
`lluchkaa` and `yurii-work` start with the same tool and package selections.
The work author identity is `Yurii Luchka <yurii@miggo.io>` for Git and
Jujutsu. Git uses `user.useConfigOnly` to refuse an inferred identity.

```nix
# users/yurii-work/home.nix
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

Each user also owns three independent Homebrew lists:

| File under `users/<username>/homebrew/` | Selection |
| --- | --- |
| `brews/default.nix` | Formulae |
| `casks/default.nix` | GUI applications |
| `mas/default.nix` | Mac App Store application IDs |

These lists were copied for both accounts so they can be edited independently.
On a shared Mac, their union is installed once: formulae/casks are deduplicated,
and conflicting MAS IDs for the same name fail evaluation. Removing an app from
one account's list does not remove it while another account still requests it.
Homebrew and most applications are machine-wide; these lists select installations,
not access restrictions. Home Manager files, Git identity, and tool configuration
remain per account.

[nix-homebrew](https://github.com/zhaofengli/nix-homebrew) now bootstraps Homebrew
on activation and adopts an existing installation through `autoMigrate`. The
primary account owns the standard prefix and runs the single Homebrew bundle;
this does not grant additional administrator permissions to other accounts.
MAS installation uses that account's App Store session.

| Darwin target | Accounts managed | Primary account |
| --- | --- | --- |
| `macbook-pro-m1-personal` | `lluchkaa` | `lluchkaa` |
| `macbook-pro-work` | `yurii-work` | `yurii-work` |
| `macbook-pro-m1` | Both | `lluchkaa` |

Use `macbook-pro-m1` for both logins on one Mac. Use the personal/work targets
for separate machines; switching a shared prefix between the single-account
targets would also change its owner and selected package set. `macbook-pro-m1-personal` selects only the personal account. No macOS login accounts are created by this
configuration: create the work login in System Settings before activating a
target that includes it. The work profile pins numeric UID 502 (verified unused on the current Mac);
create the login with that UID. This is distinct from the account’s generated UUID.

Validate all profile and tool checks with `nix flake check path:.`. Activation is
a separate step; none of these changes performs an account migration or rebuild
switch automatically.
