{ os, lib, pkgs, ... }@inputs: {
  imports = [
    ./aerospace
    ./gh
    ./ghostty
    ./git
    ./neovim
    ./ngrok
    ./tmux
  ];

  home.packages = [
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    # pkgs.nodejs

    pkgs.sqlite
    pkgs.gcc
    pkgs.luajit
    pkgs.pnpm

    pkgs.yq

    pkgs.gitmux

    pkgs.cursor-cli
  ] ++ lib.optionals (os == "darwin") [
    pkgs.cocoapods
  ];

  programs.btop = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.go = {
    enable = true;
    goPath = "dev/go";
  };

  programs.jq = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.lazydocker = {
    enable = true;
  };

  programs.lazysql = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };
}
