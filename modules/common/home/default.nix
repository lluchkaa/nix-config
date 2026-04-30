{ self, ... }:
{
  # Rotate suffix per flake update so .bak files don't stack
  # across activations (e.g. .bak-1714521600).
  home-manager.backupFileExtension = "bak-${toString (self.lastModified or 0)}";
}
