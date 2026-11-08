{ self, ... }:
{
  # Rotate suffix per flake update so .bak files don't stack
  # across activations (e.g. .bak-1714521600).
  home-manager.backupFileExtension = "bak-${toString (self.lastModified or 0)}";
  # Same suffix across rebuilds of one revision: replace the old backup instead of failing.
  home-manager.overwriteBackup = true;
}
