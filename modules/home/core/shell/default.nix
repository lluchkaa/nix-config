{
  config,
  lib,
  os,
  pkgs,
  ...
}:
{
  imports = [
    ./starship
    ./variables
  ];

  # Static brew shellenv on Apple Silicon (paths fixed under /opt/homebrew).
  # Avoids running `brew shellenv` per shell start.
  home.sessionVariables = {
    ZVM_CURSOR_STYLE_ENABLED = "false";
    ZSH_AUTOSUGGEST_MANUAL_REBIND = "1";
    ZSH_AUTOSUGGEST_USE_ASYNC = "0";
  }
  // lib.optionalAttrs (os == "darwin") {
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew/Repository";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ]
  ++ lib.optionals (os == "darwin") [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    envExtra = ''
      typeset -U path PATH fpath FPATH manpath MANPATH cdpath CDPATH
    '';
    completionInit = ''
      autoload -U compinit
      compinit -C -d "$ZDOTDIR/.zcompdump"
    '';
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
    initContent = lib.mkOrder 1000 ''
      # Re-bind autosuggestions after zvm_init redefines widgets.
      function zvm_after_init() {
        _zsh_autosuggest_bind_widgets
      }
    '';
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
