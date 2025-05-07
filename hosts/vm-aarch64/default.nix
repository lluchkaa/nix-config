{ pkgs, ... }@inputs: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    # https://github.com/mitchellh/nixos-config/blob/main/machines/vm-shared.nix#L115
    pkgs.gtkmm3
  ];
}
