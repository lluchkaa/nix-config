# nix-darwin uses --toc-depth which nixpkgs removed (PR #537810); translate until nix-darwin is patched
(_self: prev: {
  nixos-render-docs = prev.symlinkJoin {
    name = "nixos-render-docs-compat";
    paths = [
      (prev.writeShellScriptBin "nixos-render-docs" ''
        args=()
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --toc-depth|--chunk-toc-depth|--section-toc-depth)
              args+=("--sidebar-depth" "$2")
              shift 2
              ;;
            *) args+=("$1"); shift ;;
          esac
        done
        exec ${prev.nixos-render-docs}/bin/nixos-render-docs "''${args[@]}"
      '')
      prev.nixos-render-docs
    ];
    preferLocalBuild = true;
  };
})
