{
  os,
  lib,
  pkgs,
  ...
}@inputs:
{
  imports = [
    ./aerospace
    ./claude-code
    ./copilot
    ./gh
    ./ghostty
    ./git
    ./jujutsu
    ./neovim
    ./ngrok
    ./tmux
    ./zed
  ];

  home.packages = [
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    # pkgs.nodejs
    pkgs.nodejs_24

    pkgs.sqlite
    pkgs.gcc
    pkgs.luajit
    pkgs.nixfmt
    pkgs.pnpm
    pkgs.uv

    pkgs.yq

    pkgs.gitmux

    pkgs.cursor-cli
    pkgs.ngrok
    pkgs.watchman
  ]
  ++ lib.optionals (os == "darwin") [
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
