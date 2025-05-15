{ lib, ... }@inputs: {
  virtualisation.vmware.guest.enable = lib.mkDefault true;
}
