{ os, lib, pkgs, ... }@inputs: {
  home.preferXdgDirectories = true;

  xdg.portal = lib.mkIf (os == "linux") {
    enable = lib.mkDefault true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
