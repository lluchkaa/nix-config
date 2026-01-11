(self: super: {
  nix = super.nix.overrideAttrs (old: {
    doInstallCheck = false;
  });
})
