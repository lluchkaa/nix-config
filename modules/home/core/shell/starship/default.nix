{ lib, pkgs, ... }:
{
  programs.starship = {
    enable = true;

    enableTransience = true;
    settings = lib.importTOML ./starship.toml;
  };

  home.packages = [
    pkgs.jj-starship-no-git
  ];
}
