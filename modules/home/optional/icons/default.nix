{ config, ... }:
{
  home.file = {
    "${config.xdg.dataHome}/icons/claude.png".source = ./claude.png;
  };
}
