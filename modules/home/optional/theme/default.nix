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
  # Linux disabled: catppuccin sub-modules import palette/theme files
  # from derivations that require aarch64-linux native build (whiskers
  # in Rust). Re-enable once linux-builder is provisioned.
  # See https://nix.catppuccin.com/options/main/home/catppuccin/
  catppuccin = {
    enable = os == "darwin";

    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    nvim.enable = false;
    swaylock.enable = false;
    mako.enable = false;
    # Own starship.toml via programs.starship.settings; catppuccin's
    # starship build pulls in whiskers (Rust) which is fragile across systems.
    starship.enable = false;
  };
}
