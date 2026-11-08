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
    runCommand =
      name: _: _:
      "/generated/${name}";
  };
  support = import ../modules/home/core/pkgs/claude-code/lsps.nix { inherit pkgs lib; };
  sources = {
    inherit pkgs;
    anthropics-skills = "/sources/anthropics";
    matt-pocock-skills = "/sources/matt-pocock";
  };
  # No Claude configuration is provided: Codex must stand on its own.
  codex = import ../modules/home/core/pkgs/codex sources;
  catalog = import ../modules/home/core/pkgs/coding-skills sources;
in
assert builtins.length support.packages == 7;
assert builtins.length (builtins.attrNames support.servers) == 7;
# A disabled marketplace plugin must not remove its direct server or package.
assert builtins.elem "go-package" support.packages;
assert support.servers.gopls.command == "gopls";
assert support.enabledPlugins == { };
assert support.servers.typescript-lsp.extensionToLanguage.".tsx" == "typescriptreact";
assert support.servers.pyright.command == "pyright-langserver";
assert codex.programs.codex.skills == catalog;
assert !(catalog ? slack-triage);
assert builtins.length (builtins.attrNames catalog) == 6;
true
