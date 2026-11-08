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
    ./codex
    ./copilot
    ./direnv
    ./gh
    ./ghostty
    ./git
    ./go
    ./gpg
    ./jujutsu
    ./mcp
    ./neovim
    ./node
    ./tmux
  ];

  home.packages = [
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.python3

    pkgs.openssl
    pkgs.sqlite
    pkgs.gcc
    pkgs.clang-tools
    pkgs.tree-sitter
    pkgs.luajit
    pkgs.nixfmt
    pkgs.uv

    pkgs.yq
    pkgs.coreutils

    pkgs.gitmux
    pkgs.herdr
    pkgs.superfile
    pkgs.hunk
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
