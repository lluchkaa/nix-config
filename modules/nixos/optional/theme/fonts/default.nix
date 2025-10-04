{
  os,
  lib,
  pkgs,
  ...
}@inputs:
{
  fonts.fontconfig = {
    enable = os == "linux";

    hinting = {
      autohint = true;
    };

    subpixel = {
      rgba = "rgb";
    };
  };
}
