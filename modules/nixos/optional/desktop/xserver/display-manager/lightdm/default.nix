{ pkgs, ... }@inputs:
{
  services.xserver.displayManager = {
    lightdm = {
      enable = true;

      background = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;

      greeters.gtk = {
        theme = {
          name = "catppuccin-mocha-lavender-standard";
          package = pkgs.catppuccin-gtk.override {
            accents = [ "lavender" ];
            size = "standard";
            variant = "mocha";
          };
        };

        iconTheme = {
          name = "Dracula";
          package = pkgs.dracula-icon-theme;
        };

        cursorTheme = {
          name = "macOS";
          package = pkgs.apple-cursor;
        };
      };

      extraSeatDefaults = ''
        [Seat:*]
        greeter-hide-users=true
        greeter-show-manual-login=true
      '';
    };
  };
}
