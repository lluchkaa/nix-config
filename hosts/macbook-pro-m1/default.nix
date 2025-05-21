{ pkgs, ... }@inputs: {
  imports = [
    # ./hardware-configuration.nix
  ];

  system.stateVersion = 6;

  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;
}
