{ lib, pkgs, ... }@inputs:
{
  programs.starship = {
    enable = true;

    enableTransience = true;
    settings = lib.importTOML ./starship.toml;
  };

  home.packages = [
    pkgs.jj-starship
  ];
}
