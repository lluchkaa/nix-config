{ system, self, ... }@inputs: {
  imports = [
    ./i18n
    ./ssh
    ./time
  ];

  system.stateVersion = "26.05";
  system.configurationRevision = self.rev or self.dirtyRev or null;

  nixpkgs.hostPlatform = system;

  security.sudo.wheelNeedsPassword = false;
}
