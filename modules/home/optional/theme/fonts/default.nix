{ lib, pkgs, ... }@inputs: {
  home.packages = [
    pkgs.monaspace
    pkgs.nerd-fonts.fira-code
  ];

  fonts.fontconfig = {
    enable = lib.mkDefault true;

    defaultFonts = {
      monospace = [ "Monaspace Krypton Var" "FiraCode Nerd Font Mono" ];
      sansSerif = [ "FiraCode Nerd Font" "Monaspace Argon Var" ];
      serif = [ "FiraCode Nerd Font" "Monaspace Argon Var" ];
    };
  };
}
