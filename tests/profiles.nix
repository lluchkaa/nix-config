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
  personal = home "lluchkaa" [ ];
  work = home "yurii-work" [ ];
  disabled = home "yurii-work" [
    {
      programs = lib.genAttrs [ "claude-code" "codex" "neovim" "tmux" ] (_: {
        enable = lib.mkForce false;
      });
      workstation.node.enable = lib.mkForce false;
      workstation.copilot.enable = lib.mkForce false;
    }
  ];
  customized = home "yurii-work" [
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
  multi =
    (make {
      name = "profile-test";
      system = pkgs.stdenv.hostPlatform.system;
      username = "lluchkaa";
      usernames = [
        "lluchkaa"
        "yurii-work"
      ];
      inherit os;
    }).config;
  packageNames = map (package: package.pname or package.name) disabled.home.packages;
in
assert multi.users.users.yurii-work.description == "Yurii Luchka (work)";
assert multi.home-manager.users.lluchkaa.home.username == "lluchkaa";
assert multi.home-manager.users.yurii-work.home.username == "yurii-work";
assert
  multi.home-manager.users.lluchkaa.home.homeDirectory
  != multi.home-manager.users.yurii-work.home.homeDirectory;
assert os != "darwin" || (multi.nix-homebrew.enable && multi.nix-homebrew.user == "lluchkaa");
assert personal.home.username == "lluchkaa";
assert work.home.username == "yurii-work";
assert personal.home.homeDirectory != work.home.homeDirectory;
assert (work.programs.git.settings.user.email or null) != personal.programs.git.settings.user.email;
assert work.programs.git.settings.user.useConfigOnly;
assert work.programs.git.settings.user.name == "Yurii Luchka";
assert work.programs.git.settings.user.email == "yurii@miggo.io";
assert
  work.programs.jujutsu.settings.user == {
    name = "Yurii Luchka";
    email = "yurii@miggo.io";
  };
assert os != "darwin" || multi.users.users.yurii-work.uid == 502;
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
