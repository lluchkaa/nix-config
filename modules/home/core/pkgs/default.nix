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
    ./direnv
    ./gh
    ./ghostty
    ./git
    ./go
    ./gpg
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

    pkgs.openssl
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
    pkgs.coreutils

    pkgs.gitmux

    pkgs.watchman
    pkgs.nmap
  ]
  ++ lib.optionals (os == "darwin") [
    pkgs.cocoapods
  ];

  programs = {
    btop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    lazygit.enable = true;
    lazydocker.enable = true;
    lazysql.enable = true;
    ripgrep.enable = true;
  };
}
