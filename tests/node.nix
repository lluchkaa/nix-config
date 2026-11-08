{ lib }:
let
  pkgs = {
    nodejs_26 = "node-26";
    pnpm = "pnpm";
  };
  node =
    os: enabled:
    (lib.evalModules {
      specialArgs = { inherit pkgs os; };
      modules = [
        ../modules/home/core/pkgs/node
        {
          options = {
            home.packages = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
            programs.zsh.initContent = lib.mkOption {
              type = lib.types.lines;
              default = "";
            };
          };
          config.workstation.node.enable = enabled;
        }
      ];
    }).config;
in
assert
  (node "linux" true).home.packages == [
    "node-26"
    "pnpm"
  ];
assert !(lib.hasInfix "/opt/homebrew" (node "linux" true).programs.zsh.initContent);
assert lib.hasInfix "/opt/homebrew/opt/nvm/nvm.sh" (node "darwin" true).programs.zsh.initContent;
assert (node "linux" false).home.packages == [ ];
assert (node "linux" false).programs.zsh.initContent == "";
true
