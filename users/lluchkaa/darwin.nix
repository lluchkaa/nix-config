{ ... }@inputs: {
  imports = [
    ../../modules/nixos/core/nix
    ../../modules/darwin/core/system
    ../../modules/nixos/core/pkgs
    ../../modules/nixos/core/home
    ../../modules/darwin/core/homebrew

    ../../modules/users/me
  ];
}
