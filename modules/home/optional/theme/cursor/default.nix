{ os, lib, pkgs, ... }@inputs: {
  home.pointerCursor = lib.mkIf (os == "linux") {
    enable = lib.mkDefault true;
    x11.enable = lib.mkDefault true;

    name = "macOS";
    package = pkgs.apple-cursor;

    size = 128;
  };
}
