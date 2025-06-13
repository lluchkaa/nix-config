{ os, lib, ... }@inputs: {
  programs.aerospace = {
    enable = os == "darwin";
    package = null;
    userSettings = lib.importTOML ./aerospace.toml;
  };
}
