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
    stateVersion = 7;
    primaryUser = username;
  };

  # nix-darwin passes --toc-depth to nixos-render-docs which nixpkgs removed (lnl7/nix-darwin#1817)
  # both of these pull in darwin-manual-html.drv which fails; remove once nix-darwin is patched
  documentation.doc.enable = false;
  system.tools.darwin-uninstaller.enable = false;

  nixpkgs.hostPlatform = system;
}
