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
assert builtins.elem "go-package" support.packages;
assert support.servers.gopls.command == "gopls";
assert support.enabledPlugins == { };
assert support.servers.typescript-lsp.extensionToLanguage.".tsx" == "typescriptreact";
assert support.servers.pyright.command == "pyright-langserver";
true
