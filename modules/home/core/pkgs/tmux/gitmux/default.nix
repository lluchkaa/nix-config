{ config, lib, ... }:
{
  config = lib.mkIf config.programs.tmux.enable {
    xdg.configFile = {
      "gitmux/gitmux.conf".source = ./gitmux.conf;
    };

    home.file = {
      ".gitmux.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/gitmux/gitmux.conf";
    };
  };
}
