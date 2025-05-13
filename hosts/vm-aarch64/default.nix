{ pkgs, ... }@inputs: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/vm/vmware
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
