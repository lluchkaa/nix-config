{ username, pkgs, ... }@inputs: {
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

          extraConfig = ''
            show-user-list=false
            show-session=false
          '';
        };
      };

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
        '';
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

  services = {
    displayManager = {
      autoLogin = {
        enable = false;     # Do not auto-login
        user = username;    # This gets pre-selected if user list is shown
      };
      defaultSession = "none+i3";
    };
  };

  services.gvfs.enable = true;
}
