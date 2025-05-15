{ lib, pkgs, ... }@inputs: {
  home.pointerCursor = {
    enable = lib.mkDefault true;
    x11.enable = lib.mkDefault true;

    name = "macOS";
    package = pkgs.apple-cursor;
  };
}
