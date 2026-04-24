{
  pkgs,
  lib,
  config,
  claude-code-deps,
  ...
}:
let
  inherit (claude-code-deps)
    claude-plugins
    anthropics
    caveman
    matt-pocock
    chrome-devtools
    ;
  claude-plugins-official = "claude-plugins-official";
  lsps = import ./lsps.nix {
    inherit pkgs;
    claude-plugins-official = claude-plugins-official;
  };
in
{
  home.packages = map (l: l.package) (lib.filter (l: l.package != null) lsps);

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    context = ./CLAUDE.md;
    plugins = [ ];
    marketplaces = {
      claude-plugins-official = claude-plugins;
      caveman = caveman;
      chrome-devtools-plugins = chrome-devtools;
    };
    skills = {
      grill-me = "${matt-pocock}/grill-me";
      skill-creator = "${anthropics}/skills/skill-creator";
    };
    hooks = {
      "notify.sh" = builtins.replaceStrings [ "@iconsDir@" ] [ "${config.xdg.dataHome}/icons" ] (
        builtins.readFile ./notify.sh
      );
    };
    lspServers = lib.listToAttrs (
      map (l: {
        name = l.server.name;
        value = removeAttrs l.server [ "name" ];
      }) (lib.filter (l: l.server != null) lsps)
    );
    settings = {
      editorMode = "vim";
      enabledPlugins =
        lib.listToAttrs (
          map (l: {
            name = "${l.plugin}@${l.marketplace}";
            value = true;
          }) (lib.filter (l: l.plugin != null && l.enabled) lsps)
        )
        // {
          "caveman@caveman" = true;
          "chrome-devtools-mcp@chrome-devtools-plugins" = true;
        };
      hooks = import ./hooks.nix;
      allowedChannelPlugins = [
        {
          marketplace = claude-plugins-official;
          plugin = "telegram";
        }
      ];
    };
  };
}
