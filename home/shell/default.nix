{ config, pkgs, ... }@inputs: {
  imports = [
    ./starship
    ./variables.nix
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
    shellInitLast = ''
      fish_vi_key_bindings
      fish_vi_cursor
      enable_transience
    '';
  };

  xdg.configFile = {
    # fish completions for nix
    "fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
  };
}
