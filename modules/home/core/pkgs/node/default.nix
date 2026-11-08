{
  pkgs,
  lib,
  os,
  ...
}:
{
  # Both shells start with the same runtime. nvm changes it only on request.
  home.packages = [
    pkgs.nodejs_26
    pkgs.pnpm
  ];
  programs.zsh.initContent = lib.mkOrder 1000 (
    builtins.replaceStrings
      [ "@brewNvm@" ]
      [ (lib.optionalString (os == "darwin") ''"/opt/homebrew/opt/nvm/nvm.sh"'') ]
      (builtins.readFile ./nvm.zsh)
  );
}
