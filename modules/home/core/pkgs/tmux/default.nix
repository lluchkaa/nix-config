{ pkgs, ... }:
{
  imports = [
    ./gitmux
  ];

  programs.tmux = {
    enable = true;

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
    (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./tmux-sessionizer))
  ];

  home.shellAliases = {
    ts = "tmux-sessionizer";
  };
}
