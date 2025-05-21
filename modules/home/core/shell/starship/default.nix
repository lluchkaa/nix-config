{ lib, ... }@inputs: {
  programs.starship = {
    enable = lib.mkDefault true;

    enableTransience = true;
    settings = lib.importTOML ./starship.toml;
  };
}
