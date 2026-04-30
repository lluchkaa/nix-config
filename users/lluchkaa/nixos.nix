{ ... }:
{
  imports = [
    ../../modules/common/nix
    ../../modules/common/pkgs
    ../../modules/common/home
    ../../modules/common/shell
    ../../modules/nixos/core/system
    ../../modules/nixos/core/xdg

    ../../modules/nixos/optional/desktop/xserver
    ../../modules/nixos/optional/theme

    ../../modules/users/me
  ];
}
