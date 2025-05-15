{ lib, pkgs, ... }@inputs: {
  imports = [
    ./cursor
    ./fonts
  ];

  home.file = {
    ".background-image".source = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
  };

  catppuccin = {
    enable = lib.mkDefault true;

    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    swaylock.enable = false;
    mako.enable = false;
  };
}
