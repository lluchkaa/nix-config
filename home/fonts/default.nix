{ pkgs, ... }@inputs: {
  home.packages = [
    pkgs.monaspace
    pkgs.nerd-fonts.fira-code
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [ "Monaspace Krypton Var" "FiraCode Nerd Font Mono" ];
      sansSerif = [ "Monaspace Argon Var" "FiraCode Nerd Font" ];
      serif = [ "Monaspace Argon Var" "FiraCode Nerd Font" ];
    };
  };
}
