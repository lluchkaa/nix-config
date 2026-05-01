{
  os,
  pkgs,
  ...
}:
let
  fonts = import ../../../../common/theme/fonts.nix pkgs;
in
{
  home.packages = fonts;

  fonts.fontconfig = {
    enable = os == "linux";

    defaultFonts = {
      monospace = [
        "Monaspace Krypton Var"
        "FiraCode Nerd Font Mono"
      ];
      sansSerif = [
        "FiraCode Nerd Font"
        "Monaspace Argon Var"
      ];
      serif = [
        "FiraCode Nerd Font"
        "Monaspace Argon Var"
      ];
    };
  };
}
