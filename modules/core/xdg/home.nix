{ config, pkgs, ... }@inputs: {
  home.preferXdgDirectories = true;

  xresources.extraConfig = builtins.readFile ./XResources;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}

