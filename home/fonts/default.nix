{ ... }@inputs: {

  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Monaspace" "FiraCode" ]; })
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
