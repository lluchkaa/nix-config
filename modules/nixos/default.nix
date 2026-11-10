{ ... }:
{
  imports = [
    ../common/nix
    ../common/pkgs
    ../common/home
    ../common/shell
    ./core/system
    ./core/xdg

    ./optional/desktop/xserver
    ./optional/theme
  ];
}
