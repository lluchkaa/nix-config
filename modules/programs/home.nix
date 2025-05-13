{ username, os, lib, pkgs, ... }@inputs: {
  imports = [
    ./ghostty.nix
  ];

  home.packages = [
    pkgs.ghostty

    pkgs.neovim

    pkgs.sqlite
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.nodejs
  ] ++ (lib.optionals (os == "linux") [
    pkgs.chromium
    pkgs.xfce.xfce4-terminal
  ]);

  programs.git = {
    enable = true;
    # rest should be set in users/*/home.nix file
  };

  programs.go = {
    enable = true;
    goPath = "dev/go";
  };

  programs.command-not-found = {
    dbPath = "${pkgs.sqlite}";
  };
  
  programs.direnv = {
    enable = true;
  };
}
