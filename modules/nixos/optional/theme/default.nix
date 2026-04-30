{ ... }:
{
  imports = [
    ./fonts
  ];

  # System-level catppuccin (TTY palette, plymouth) disabled because its
  # palette derivation runs `whiskers` (Rust) natively at eval time,
  # which can't be evaluated cross-arch from aarch64-darwin without a
  # linux-builder. Per-user app themes still active via
  # modules/home/optional/theme.
  # See https://nix.catppuccin.com/options/main/nixos/catppuccin/
  catppuccin.enable = false;
}
