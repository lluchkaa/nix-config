{ pkgs, config, claude-plugins, ... }:
{
  home.packages = [
    pkgs.typescript-language-server
    pkgs.gopls
    pkgs.vscode-langservers-extracted
    pkgs.lua-language-server
    pkgs.rustup
  ];

  programs.claude-code = {
    enable = true;
    plugins = map (name: "${claude-plugins}/plugins/${name}") [
      "clangd-lsp"
      "gopls-lsp"
      "lua-lsp"
      "pyright-lsp"
      "rust-analyzer-lsp"
      "typescript-lsp"
    ];
    hooks = {
      "notify.sh" = builtins.replaceStrings
        [ "@iconsDir@" ]
        [ "${config.xdg.dataHome}/icons" ]
        (builtins.readFile ./notify.sh);
    };
    lspServers = {
      typescript-lsp = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };
      gopls = {
        command = "gopls";
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      vscode-json-language-server = {
        command = "vscode-json-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".json" = "json";
          ".jsonc" = "jsonc";
        };
      };
      lua-language-server = {
        command = "lua-language-server";
        extensionToLanguage = {
          ".lua" = "lua";
        };
      };
      rust-analyzer = {
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
    };
    settings = {
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
