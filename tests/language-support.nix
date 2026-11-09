{ lib }:
let
  pkgs = {
    typescript-language-server = "typescript-package";
    gopls = "go-package";
    vscode-langservers-extracted = "json-package";
    lua-language-server = "lua-package";
    rustup = "rust-package";
    clang-tools = "clang-package";
    pyright = "python-package";
  };
  support = import ../modules/home/core/pkgs/claude-code/lsps.nix { inherit pkgs lib; };
in
assert builtins.length support.packages == 7;
assert builtins.length (builtins.attrNames support.servers) == 7;
# A disabled marketplace plugin must not remove its direct server or package.
assert builtins.elem "clang-package" support.packages;
assert support.servers.clangd.command == "clangd";
assert support.enabledPlugins == {
  "typescript-lsp@claude-plugins" = true;
  "pyright-lsp@claude-plugins" = true;
  "gopls-lsp@claude-plugins" = true;
  "lua-lsp@claude-plugins" = true;
  "rust-analyzer-lsp@claude-plugins" = true;
};
assert support.servers.typescript-lsp.extensionToLanguage.".tsx" == "typescriptreact";
assert support.servers.pyright.command == "pyright-langserver";
true
