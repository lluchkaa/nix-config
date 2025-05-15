{ lib, pkgs, ... }@inputs: {
  imports = [
    ./display-manager/lightdm
    ./window-manager/i3
  ];

  services.xserver = {
    enable = true;
    xkb.layout = lib.mkDefault "us,ua";
    dpi = lib.mkDefault 227;

    desktopManager = {
      xterm.enable = lib.mkDefault false;
      wallpaper.mode = lib.mkDefault "fill";
    };

    displayManager = {
      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';

      # setupCommands = ''
      #   ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1200
      # '';
    };
  };

  services = {
    displayManager = {
      defaultSession = "none+i3";
    };
  };

  services.gvfs.enable = true;
}
