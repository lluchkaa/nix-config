{ os, lib, ... }@inputs:
{
  programs.aerospace = {
    enable = os == "darwin";
    # package = null;
    settings = lib.importTOML ./aerospace.toml;
    launchd.enable = true;
  };
}
