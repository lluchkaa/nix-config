{
  config,
  os,
  lib,
  ...
}:
{
  config = lib.mkIf (config.programs.aerospace.enable && os == "darwin") {
    programs.aerospace = lib.mkDefault {
      # package = null;
      settings = lib.importTOML ./aerospace.toml;
      launchd.enable = true;
    };
  };
}
