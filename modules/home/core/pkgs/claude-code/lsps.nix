{ pkgs, claudePluginsOfficial }:
[
  {
    enabled = true;
    package = pkgs.typescript-language-server;
    plugin = null;
    marketplace = null;
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
    enabled = false;
    package = pkgs.gopls;
    plugin = "gopls-lsp";
    marketplace = claudePluginsOfficial;
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
    enabled = false;
    package = pkgs.vscode-langservers-extracted;
    plugin = null;
    marketplace = null;
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
    enabled = false;
    package = pkgs.lua-language-server;
    plugin = "lua-lsp";
    marketplace = claudePluginsOfficial;
    server = {
      name = "lua-language-server";
      command = "lua-language-server";
      extensionToLanguage = {
        ".lua" = "lua";
      };
    };
  }
  {
    enabled = false;
    package = pkgs.rustup;
    plugin = "rust-analyzer-lsp";
    marketplace = claudePluginsOfficial;
    server = {
      name = "rust-analyzer";
      command = "rust-analyzer";
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
  }
  {
    enabled = false;
    package = pkgs.clang-tools;
    plugin = "clangd-lsp";
    marketplace = claudePluginsOfficial;
    server = {
      name = "clangd";
      command = "clangd";
      extensionToLanguage = {
        ".c" = "c";
        ".h" = "c";
        ".cpp" = "cpp";
        ".cc" = "cpp";
        ".cxx" = "cpp";
        ".hpp" = "cpp";
      };
    };
  }
  {
    enabled = true;
    package = pkgs.pyright;
    plugin = null;
    marketplace = null;
    server = {
      name = "pyright";
      command = "pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
      };
    };
  }
]
