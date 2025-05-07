{ pkgs, ... }@inputs: {
  imports = [
    ./starship.nix
    ./variables.nix
  ];

  home.sessionVariables = {
    ZVM_CURSOR_STYLE_ENABLED = "false";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    defaultKeymap = "viins";

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.fish = {
    enable = true;
  };
}
