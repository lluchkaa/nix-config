{
  pkgs,
  lib,
  config,
  claude-plugins,
  anthropics-skills,
  caveman,
  matt-pocock-skills,
  chrome-devtools-mcp,
  ponytail,
  ...
}:
let
  claudePluginsOfficial = "claude-plugins";
  languageSupport = import ./lsps.nix { inherit pkgs lib; };
in
{
  home.packages = languageSupport.packages;

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    configDir = "${config.xdg.configHome}/claude";
    context = ./CLAUDE.md;
    plugins = [ ];
    marketplaces = {
      inherit claude-plugins;
      inherit caveman;
      chrome-devtools-plugins = chrome-devtools-mcp;
      inherit ponytail;
    };
    skills = import ../coding-skills { inherit pkgs anthropics-skills matt-pocock-skills; };
    lspServers = languageSupport.servers;
    settings = {
      model = "sonnet";
      editorMode = "vim";
      enabledPlugins = languageSupport.enabledPlugins // {
        "chrome-devtools-mcp@chrome-devtools-plugins" = false;
        "ponytail@ponytail" = true;
      };
      allowedChannelPlugins = [
        {
          marketplace = claudePluginsOfficial;
          plugin = "telegram";
        }
      ];
      agentPushNotifEnabled = true;
      statusLine = {
        type = "command";
        command = "starship statusline claude-code";
      };
    };
  };
}
