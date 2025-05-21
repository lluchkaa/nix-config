{ ... }@inputs: {
  imports = [
    ../../modules/nixos/core/nix
    ../../modules/darwin/core/system
    ../../modules/nixos/core/pkgs
    ../../modules/nixos/core/shell
    ../../modules/nixos/core/home

    ../../modules/users/me
  ];
}
