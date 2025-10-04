{
  os,
  lib,
  pkgs,
  ...
}@inputs:
{
  programs.chromium = {
    enable = os == "linux";
  };
}
