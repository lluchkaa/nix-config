{ lib, ... }@inputs: {
  programs.starship = {
    enable = true;

    # read ./starship.toml file
    settings = lib.importTOML ./starship.toml;
  };
}
