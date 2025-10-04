{
  os,
  lib,
  pkgs,
  ...
}@inputs:
{
  home.packages = [
    pkgs.monaspace
    pkgs.nerd-fonts.fira-code
  ];

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
