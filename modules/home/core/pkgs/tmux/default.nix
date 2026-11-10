{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./gitmux
  ];

  config = lib.mkIf config.programs.tmux.enable {
    programs.tmux = lib.mkDefault {

      terminal = "tmux-256color";
      shortcut = "a";
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      mouse = true;
      baseIndex = 1;
      clock24 = true;
      disableConfirmationPrompt = true;
      escapeTime = 0;
      historyLimit = 50000;
      focusEvents = true;
      resizeAmount = 10;

      plugins = [
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.battery
        pkgs.tmuxPlugins.vim-tmux-navigator
        (pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-nerd-font-window-name";
          version = "3.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "joshmedeski";
            repo = "tmux-nerd-font-window-name";
            rev = "v3.0.0";
            sha256 = "sha256-0goD7Rl0KtNxipQUsKdI2TrrTR7AuuIS46tQtTMIQtg=";
          };
        })
      ];

      extraConfig = (builtins.readFile ./tmux.conf) + ''set -g default-command "''${SHELL}"'';
    };

    catppuccin.tmux = {
      extraConfig = builtins.readFile ./tmux.catppuccin.conf;
    };

    home.packages = [
      pkgs.gitmux
      (pkgs.writeShellApplication {
        name = "tmux-sessionizer";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.fzf
          pkgs.tmux
        ];
        text = builtins.readFile ./tmux-sessionizer;
      })
    ];

    home.shellAliases = {
      ts = "tmux-sessionizer";
    };
  };
}
