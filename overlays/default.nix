{ jj-starship }:
[
  (import ./nix)
  (import ./dmenu)
  (import ./jj-starship { inherit jj-starship; })
  (import ./direnv)
]
