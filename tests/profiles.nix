{ pkgs, inputs }:
let
  inherit (pkgs) lib;
  os = if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "linux";
  profilePkgs = pkgs.appendOverlays (
    import ../overlays {
      inherit (inputs) jj-starship claude-code-nix codex-cli-nix;
    }
  );
  home =
    username: extraModules:
    (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = profilePkgs;
      extraSpecialArgs = inputs // {
        inherit username os;
      };
      modules = [
        ../users/${username}/home.nix
      ]
      ++ extraModules;
    }).config;
  enabled = home "lluchkaa" [ ];
  disabled = home "lluchkaa" [
    {
      programs = lib.genAttrs [ "claude-code" "codex" "neovim" "tmux" ] (_: {
        enable = lib.mkForce false;
      });
      workstation.node.enable = lib.mkForce false;
      workstation.copilot.enable = lib.mkForce false;
    }
  ];
  customized = home "lluchkaa" [
    {
      programs = {
        git = {
          enable = lib.mkForce true;
          settings.pull.rebase = false;
        };
        ghostty = {
          enable = lib.mkForce true;
          settings.font-size = 15;
        };
      };
    }
  ];
  make = import ../lib/make.nix {
    inherit inputs;
    inherit (inputs) nixpkgs;
    overlays = import ../overlays {
      inherit (inputs) jj-starship claude-code-nix codex-cli-nix;
    };
  };
  systemConfig =
    (make {
      name = "profile-test";
      system = pkgs.stdenv.hostPlatform.system;
      username = "lluchkaa";
      inherit os;
    }).config;
  packageNames = map (package: package.pname or package.name) disabled.home.packages;
in
assert builtins.attrNames inputs.self.darwinConfigurations == [ "macbook-pro-m1" ];
assert builtins.attrNames systemConfig.home-manager.users == [ "lluchkaa" ];
assert
  builtins.attrNames inputs.self.darwinConfigurations.macbook-pro-m1.config.home-manager.users
  == [ "lluchkaa" ];
assert systemConfig.home-manager.users.lluchkaa.home.username == "lluchkaa";
assert
  os != "darwin"
  || (systemConfig.nix-homebrew.enable && systemConfig.nix-homebrew.user == "lluchkaa");
assert enabled.home.username == "lluchkaa";
assert enabled.programs.git.settings.user.useConfigOnly;
assert enabled.programs.git.settings.user.email == "lluchkaa@gmail.com";
assert
  enabled.programs.jujutsu.settings.user == {
    name = "Yura Luchka";
    email = "lluchkaa@gmail.com";
  };
assert os != "darwin" || systemConfig.users.users.lluchkaa.uid == 501;
assert !(disabled.xdg.configFile ? nvim);
assert !(disabled.xdg.configFile ? "gitmux/gitmux.conf");
assert !(disabled.home.shellAliases ? ts);
assert !(builtins.elem "tmux-sessionizer" packageNames);
assert !(builtins.elem "gitmux" packageNames);
assert !(builtins.elem "gopls" packageNames);
assert !(builtins.elem "nodejs" packageNames);
assert !(builtins.elem "github-copilot-cli" packageNames);
assert !(lib.hasInfix "nvm()" disabled.programs.zsh.initContent);
assert customized.programs.git.settings.pull.rebase == false;
assert customized.programs.ghostty.settings.font-size == [ 15 ];
true
