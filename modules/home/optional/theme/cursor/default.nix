{
  os,
  lib,
  pkgs,
  ...
}@inputs:
{
  home.pointerCursor = lib.mkIf (os == "linux") {
    enable = true;
    x11.enable = true;

    name = "macOS";
    package = pkgs.apple-cursor;
  };
}
