_self: super: {
  direnv =
    if super.stdenv.isDarwin then
      super.direnv.overrideAttrs (_: {
        doCheck = false;
      })
    else
      super.direnv;
}
