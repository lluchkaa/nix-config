{ jj-starship, claude-code-nix }:
[
  (import ./nix)
  (import ./dmenu)
  (import ./jj-starship { inherit jj-starship; })
  (import ./direnv)
  claude-code-nix.overlays.default
]
