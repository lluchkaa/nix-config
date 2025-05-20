{ os, lib, pkgs, ... }@inputs: {
  programs.chromium = {
    enable = lib.mkDefault os == "linux";
  };
}
