{ lib, ... }@inputs: {
  programs.starship = {
    enable = lib.mkDefault true;

    settings = lib.importTOML ./starship.toml;
  };
}
