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
  }
  // lib.optionalAttrs (os == "darwin") {
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew/Repository";
  };

  home.sessionPath = lib.optionals (os == "darwin") [
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
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
    initContent = lib.mkOrder 1000 ''
      # Lazy-load nvm: shim node/npm/npx/nvm; first call sources nvm.sh once.
      export NVM_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
      _nvm_lazy_load() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      }
      nvm()  { _nvm_lazy_load; nvm  "$@"; }
      node() { _nvm_lazy_load; node "$@"; }
      npm()  { _nvm_lazy_load; npm  "$@"; }
      npx()  { _nvm_lazy_load; npx  "$@"; }
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
