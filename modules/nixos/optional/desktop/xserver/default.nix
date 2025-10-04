{ lib, pkgs, ... }@inputs:
{
  imports = [
    ./display-manager/lightdm
    ./window-manager/i3
  ];

  services.xserver = {
    enable = true;
    xkb.layout = "us,ua";
    dpi = 180;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';

      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --preferred
      '';
    };
  };

  services = {
    displayManager = {
      defaultSession = "none+i3";
    };
  };

  services.gvfs.enable = true;
}
