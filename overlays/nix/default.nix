(_self: super: {
  nix = super.nix.overrideAttrs (_old: {
    doInstallCheck = false;
  });
})
