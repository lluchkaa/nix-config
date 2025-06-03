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
    pkgs.nodejs

    pkgs.sqlite
    pkgs.gcc
    pkgs.luajit
    pkgs.pnpm

    pkgs.yq

    pkgs.gitmux
  ] ++ lib.optionals (os == "darwin") [
    pkgs.cocoapods
  ];

  programs.btop = {
    enable = lib.mkDefault true;
  };

  programs.direnv = {
    enable = lib.mkDefault true;
  };

  programs.fzf = {
    enable = lib.mkDefault true;
  };

  programs.go = {
    enable = lib.mkDefault true;
    goPath = "dev/go";
  };

  programs.jq = {
    enable = lib.mkDefault true;
  };

  programs.lazygit = {
    enable = lib.mkDefault true;
  };

  programs.lazydocker = {
    enable = lib.mkDefault true;
  };

  programs.ripgrep = {
    enable = lib.mkDefault true;
  };
}
