_self: super: {
  direnv =
    if super.stdenv.isDarwin then
      super.direnv.overrideAttrs (_: {
      })
    else
      super.direnv;
}
