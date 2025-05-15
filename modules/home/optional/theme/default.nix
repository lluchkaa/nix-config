{ pkgs, ... }@inputs: {
  imports = [
    ./cursor
    ./fonts
  ];

  home.file = {
    ".background-image".source = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
  };

  catppuccin = {
    enable = true;

    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    swaylock.enable = false;
    mako.enable = false;
  };

  # stylix = {
  #   enable = false;
  #   autoEnable = false;
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  # };
}
