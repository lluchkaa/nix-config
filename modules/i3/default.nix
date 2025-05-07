{ pkgs, ... }@inputs: {
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      lightdm.enable = true;

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
        '';
    };

    virtualScreen = {
      x = 2560;
      y = 1440;
    };

    windowManager = {
      i3 = {
        enable = true;
        # https://github.com/ryan4yin/nix-config/blob/i3-kickstarter/modules/i3.nix
        # extraPackages = with pkgs; [
        #   rofi # application launcher, the same as dmenu
        #   dunst # notification daemon
        #   i3blocks # status bar
        #   i3lock # default i3 screen locker
        #   xautolock # lock screen after some time
        #   i3status # provide information to i3bar
        #   i3-gaps # i3 with gaps
        #   picom # transparency and shadows
        #   feh # set wallpaper
        #   acpi # battery information
        #   arandr # screen layout manager
        #   dex # autostart applications
        #   xbindkeys # bind keys to commands
        #   xorg.xbacklight # control screen brightness
        #   xorg.xdpyinfo # get screen information
        #   sysstat # get system information
        # ];
      };
    };
  };

  services.displayManager = {
    defaultSession = "none+i3";
  };

  services.gvfs.enable = true;
}
