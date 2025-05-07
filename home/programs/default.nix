{ pkgs, ... }@inputs: {
  home.packages = [
    pkgs.google-chrome
    pkgs.ghostty

    pkgs.neovim

    pkgs.go
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.nodejs
  ];
}
