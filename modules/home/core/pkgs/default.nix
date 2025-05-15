{ os, lib, pkgs, ... }@inputs: {
  imports = [
    ./ghostty
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
  ]);

  programs.git = {
    enable = lib.mkDefault true;
    # rest should be set in users/*/home.nix file
  };

  programs.go = {
    enable = lib.mkDefault true;
    goPath = "dev/go";
  };

  programs.command-not-found = {
    enable = lib.mkDefault true;
    dbPath = "${pkgs.sqlite}";
  };
  
  programs.direnv = {
    enable = lib.mkDefault true;
  };
}
