{ pkgs, ... }:
let
  fonts = import ../../../../common/theme/fonts.nix pkgs;
in
{
  fonts.packages = fonts;
}
