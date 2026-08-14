_self: super: {
  direnv =
    if super.stdenv.hostPlatform.isDarwin then
      super.direnv.overrideAttrs (_: {
      })
    else
      super.direnv;
}
