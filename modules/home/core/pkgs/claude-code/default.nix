{
  pkgs,
  lib,
  config,
  claude-plugins,
  caveman,
  ...
}:
let
  lsps = [
    {
      package = pkgs.typescript-language-server;
      plugin = "typescript-lsp";
      server = {
        name = "typescript-lsp";
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };
    }
    {
      package = pkgs.gopls;
      plugin = "gopls-lsp";
      server = {
        name = "gopls";
        command = "gopls";
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    }
    {
      package = pkgs.vscode-langservers-extracted;
      plugin = null;
      server = {
        name = "vscode-json-language-server";
        command = "vscode-json-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".json" = "json";
          ".jsonc" = "jsonc";
        };
      };
    }
    {
      package = pkgs.lua-language-server;
      plugin = "lua-lsp";
      server = {
        name = "lua-language-server";
        command = "lua-language-server";
        extensionToLanguage = {
          ".lua" = "lua";
        };
      };
    }
    {
      package = pkgs.rustup;
      plugin = "rust-analyzer-lsp";
      server = {
        name = "rust-analyzer";
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
    }
    {
      package = null;
      plugin = "clangd-lsp";
      server = null;
    }
    {
      package = null;
      plugin = "pyright-lsp";
      server = null;
    }
  ];
in
{
  home.packages = map (l: l.package) (lib.filter (l: l.package != null) lsps);

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    context = ./CLAUDE.md;
    plugins = map (l: "${claude-plugins}/plugins/${l.plugin}") (lib.filter (l: l.plugin != null) lsps);
    marketplaces = {
      claude-plugins-official = claude-plugins;
      caveman = caveman;
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
            name = "${l.plugin}@claude-plugins-official";
            value = true;
          }) (lib.filter (l: l.plugin != null) lsps)
        )
        // {
          "caveman@caveman" = true;
        };
      hooks = {
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "bash $HOME/.claude/hooks/notify.sh \"Claude Code\" \"Claude needs your attention\"";
              }
            ];
          }
        ];
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "bash $HOME/.claude/hooks/notify.sh \"Claude Code\" \"Task completed\"";
              }
            ];
          }
        ];
      };
    };
  };
}
