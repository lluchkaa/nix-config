{ pkgs, ... }@inputs: {
  services.xserver = {
    enable = true;
    xkb.layout = "us,ua";
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      lightdm = {
        enable = true;

        background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;

        greeters.gtk = {
          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };

          iconTheme = {
            name = "Dracula";
            package = pkgs.dracula-icon-theme;
          };

          cursorTheme = {
            name = "Dracula-cursors";
            package = pkgs.dracula-theme;
          };
        };

        extraSeatDefaults = ''
          [Seat:*]
          greeter-hide-users=true
          greeter-show-manual-login=true
        '';
      };

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';

      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1200
      '';
    };

    windowManager = {
      i3 = {
        enable = true;

        # https://github.com/ryan4yin/nix-config/blob/i3-kickstarter/modules/i3.nix
        # extraPackages = [];
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
