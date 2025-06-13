{ lib, pkgs, ... }@inputs: {
  imports = [
    ./starship
    ./variables
  ];

  home.sessionVariables = {
    ZVM_CURSOR_STYLE_ENABLED = "false";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.fish = {
    enable = true;
    shellInitLast = ''
      set -g fish_greeting ""

      fish_vi_key_bindings
      fish_vi_cursor
      for mode in default insert replace visual; set -g fish_cursor_$mode block; end
    '';
  };
}
