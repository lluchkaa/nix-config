{ lib, pkgs, ... }@inputs: {
  imports = [
    ./starship
    ./variables
  ];

  home.sessionVariables = {
    ZVM_CURSOR_STYLE_ENABLED = "false";
  };

  programs.zsh = {
    enable = lib.mkDefault true;
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
      fish_vi_key_bindings
      fish_vi_cursor
    '';
  };
}
