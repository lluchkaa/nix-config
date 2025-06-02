{ os, lib, ... }@inputs: {
  programs.aerospace = {
    enable = lib.mkDefault os == "darwin";
    userSettings = lib.importTOML ./aerospace.toml;
  };
}
