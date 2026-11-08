{ lib }:
let
  pkgs = {
    nodejs_26 = "node-26";
    pnpm = "pnpm";
  };
  node = os: import ../modules/home/core/pkgs/node { inherit pkgs lib os; };
in
assert
  (node "linux").home.packages == [
    "node-26"
    "pnpm"
  ];
assert !(lib.hasInfix "/opt/homebrew" (node "linux").programs.zsh.initContent.content);
assert lib.hasInfix "/opt/homebrew/opt/nvm/nvm.sh" (node "darwin").programs.zsh.initContent.content;
true
