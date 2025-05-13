{ pkgs, ... }@inputs: {
  services.xserver = {
    enable = true;
    xkb.layout = "us,ua";
    dpi = 227;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      gdm = {
        enable = true;
        wayland = false;
      };

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';

      # setupCommands = ''
      #   ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1200
      # '';
    };

    windowManager = {
      i3 = {
        enable = true;
      };
    };
  };

  services = {
    displayManager = {
      defaultSession = "none+i3";
    };
  };

  services.gvfs.enable = true;
}
