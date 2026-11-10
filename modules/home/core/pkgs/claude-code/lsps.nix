{ pkgs, lib }:
let
  claudePluginsOfficial = "claude-plugins";
  # All records declare direct servers. This flag controls optional marketplace plugins only.
  languages = [
    {
      pluginEnabled = true;
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
      pluginEnabled = true;
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
      pluginEnabled = false;
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
      pluginEnabled = true;
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
      pluginEnabled = true;
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
      pluginEnabled = false;
      package = pkgs.clang-tools;
      plugin = "clangd-lsp";
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
      pluginEnabled = true;
      package = pkgs.pyright;
      plugin = "pyright-lsp";
      server = {
        name = "pyright";
        command = "pyright-langserver";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".py" = "python";
        };
      };
    }
  ];
in
{
  packages = map (language: language.package) languages;
  servers = lib.listToAttrs (
    map (language: {
      inherit (language.server) name;
      value = removeAttrs language.server [ "name" ];
    }) languages
  );
  enabledPlugins = lib.listToAttrs (
    map (language: {
      name = "${language.plugin}@${claudePluginsOfficial}";
      value = true;
    }) (lib.filter (language: language.plugin != null && language.pluginEnabled) languages)
  );
}
