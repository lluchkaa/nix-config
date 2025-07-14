{ lib, pkgs, ... }@inputs:
{
  imports = [
    ./gitmux
  ];

  programs.tmux = {
    enable = true;

    terminal = "screen-256color";
    shortcut = "a";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    mouse = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    escapeTime = 100;
    historyLimit = 10000;
    focusEvents = true;
    resizeAmount = 10;

    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.battery
      pkgs.tmuxPlugins.vim-tmux-navigator
      (pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-nerd-font-window-name";
        version = "2.1.2";
        src = pkgs.fetchFromGitHub {
          owner = "joshmedeski";
          repo = "tmux-nerd-font-window-name";
          rev = "main";
          sha256 = "sha256-UcfEsq7BqJMeYXtGDNMoi/E+iEnEe9iM2KVoi7ektOE=";
        };
      })
    ];

    extraConfig = (builtins.readFile ./tmux.conf)
      + "set -g default-command ${pkgs.zsh}/bin/zsh";
  };

  catppuccin.tmux = {
    extraConfig = builtins.readFile ./tmux.catppuccin.conf;
  };

  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ./tmux-sessionizer))
  ];

  home.shellAliases = {
    ts = "tmux-sessionizer";
  };
}
