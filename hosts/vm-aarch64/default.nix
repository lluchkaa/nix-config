{ pkgs, ... }@inputs: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
