{
  os,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./cursor
    ./fonts
  ];

  home.file = lib.mkIf (os == "linux") {
    ".background-image".source = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
  };

  # Per-user app themes (zsh, btop, bat, fzf, gtk, ghostty, ...).
  # System-level palette is set in modules/nixos/optional/theme.
  # See https://nix.catppuccin.com/options/main/home/catppuccin/
  catppuccin = {
    enable = true;

    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    nvim.enable = false;
    swaylock.enable = false;
    mako.enable = false;
  };
}
