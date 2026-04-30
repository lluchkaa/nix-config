{ ... }:
{
  services.xserver.windowManager = {
    i3 = {
      enable = true;
    };
  };

  # Also enabled in xserver/default.nix so each module works in isolation.
  # Nix merges identical bool values; safe duplication.
  services.gvfs.enable = true;
}
