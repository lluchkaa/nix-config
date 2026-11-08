{ ... }:
{
  imports = [
    ../common/nix
    ../common/pkgs
    ../common/home
    ../common/shell
    ./core/system
    ./core/homebrew
  ];
}
