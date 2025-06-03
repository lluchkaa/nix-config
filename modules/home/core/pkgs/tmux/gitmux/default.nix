{ config, lib, ... }@inputs: {
  xdg.configFile = {
    "gitmux/gitmux.conf".source = ./gitmux.conf;
  };

  home.file = {
    ".gitmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/gitmux/gitmux.conf";
  };
}
