{ ... }@inputs: {
  imports = [
    ../../modules/nixos/core/nix
    ../../modules/nixos/core/pkgs
    ../../modules/nixos/core/system
    ../../modules/nixos/core/xdg
    ../../modules/nixos/core/home

    ../../modules/nixos/optional/desktop/xserver
    ../../modules/nixos/optional/theme

    ../../modules/users/me
  ];
}
