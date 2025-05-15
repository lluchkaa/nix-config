{ pkgs, ... }@inputs: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/optional/vm/vmware
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
