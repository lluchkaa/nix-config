{ os, lib, ... }@inputs: {
  programs.aerospace = {
    enable = lib.mkDefault os == "darwin";
    package = null;
    userSettings = lib.importTOML ./aerospace.toml;
  };
}
