{
  config,
  lib,
  pkgs,
  ...
}@inputs:
{
  imports = [
    ./starship
    ./variables
  ];

  home.sessionVariables = {
    ZVM_CURSOR_STYLE_ENABLED = "false";
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    history = {
      share = false;
    };
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
    initContent = lib.mkOrder 1000 ''
      eval "$(/opt/homebrew/bin/brew shellenv)"

      export NVM_DIR="$([ -z "''${XDG_CONFIG_HOME-}" ] && printf %s "''${HOME}/.nvm" || printf %s "''${XDG_CONFIG_HOME}/nvm")"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    '';
  };

  programs.fish = {
    enable = true;
    shellInitLast = ''
      set -g fish_greeting ""

      fish_vi_key_bindings
      fish_vi_cursor
      for mode in default insert replace visual; set -g fish_cursor_$mode block; end

      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
