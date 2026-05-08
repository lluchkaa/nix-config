{
  username,
  system,
  self,
  ...
}:
{
  imports = [
    ./defaults
    ./keyboard
    ./linux-builder
    ./security
    ./theme
  ];

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
    primaryUser = username;
  };

  nixpkgs.hostPlatform = system;
}
