{ config, ... }:
{
  home.file = {
    "${config.xdg.dataHome}/icons/claude.png".source = ./claude.png;
    "${config.xdg.dataHome}/icons/claude-code.png".source = ./claude-code.png;
  };
}
