{
  os,
  lib,
  pkgs,
  ...
}:
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
    ./tmux
  ];

  home.packages = [
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.nodejs_24
    pkgs.python3

    pkgs.sqlite
    pkgs.gcc
    pkgs.clang-tools
    pkgs.tree-sitter
    pkgs.luajit
    pkgs.nixfmt
    pkgs.nixd
    pkgs.pnpm
    pkgs.uv

    pkgs.yq

    pkgs.gitmux

    pkgs.cursor-cli
    pkgs.watchman
    pkgs.nmap
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
