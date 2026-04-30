{ ... }:
{
  imports = [
    ./fonts
  ];

  # System-level: TTY palette, plymouth, etc.
  # Per-user app themes are configured in modules/home/optional/theme.
  # See https://nix.catppuccin.com/options/main/nixos/catppuccin/
  catppuccin = {
    enable = true;
  };
}
