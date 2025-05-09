{ username, pkgs, ... }@inputs: {
  imports = [
    ./ghostty.nix
  ];

  home.packages = [
    pkgs.chromium
    pkgs.ghostty

    pkgs.neovim

    pkgs.sqlite
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.nodejs
  ];

  programs.go = {
    enable = true;
    goPath = "dev/go";
  };

  programs.git = {
    enable = true;
    userName = username;
    userEmail = "lluchkaa@gmail.com";
  };

  programs.command-not-found = {
    dbPath = "${pkgs.sqlite}";
  };
}
