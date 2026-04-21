{
  pkgs,
  lib,
  config,
  claude-code-deps,
  ...
}:
let
  inherit (claude-code-deps) claude-plugins caveman matt-pocock;
  claude-plugins-official-marketplace = "claude-plugins-official";
  lsps = import ./lsps.nix {
    inherit pkgs;
    claude-plugins-official-marketplace = claude-plugins-official-marketplace;
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
    };
    skills = {
      grill-me = "${matt-pocock}/grill-me";
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
      enabledPlugins =
        lib.listToAttrs (
          map (l: {
            name = "${l.plugin}@${l.marketplace}";
            value = true;
          }) (lib.filter (l: l.plugin != null && l.enabled) lsps)
        )
        // {
          "caveman@caveman" = true;
          "superpowers@${claude-plugins-official-marketplace}" = true;
        };
      hooks = import ./hooks.nix;
    };
  };
}
