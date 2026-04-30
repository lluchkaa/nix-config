{ ... }:
{
  # Spin up an aarch64-linux QEMU VM as a remote builder so darwin can
  # build NixOS configs (e.g. vm-aarch64) without an external builder.
  # Disabled by default; flip to true when testing aarch64-linux builds.
  nix.linux-builder = {
    enable = false;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 4;
      };
    };
  };

  # Required so root nix-daemon can SSH into the builder VM.
  nix.settings.trusted-users = [ "@admin" ];
}
