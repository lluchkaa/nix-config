{
  username,
  system,
  self,
  ...
}@inputs:
{
  imports = [
    ./defaults
    ./keyboard
    ./security
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 6;

  nixpkgs.hostPlatform = system;

  system.primaryUser = username;
}
