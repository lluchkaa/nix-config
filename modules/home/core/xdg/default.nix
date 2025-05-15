{ lib, pkgs, ... }@inputs: {
  home.preferXdgDirectories = true;

  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
