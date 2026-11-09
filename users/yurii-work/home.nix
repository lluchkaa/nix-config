{
  pkgs,
  lib,
  os,
  ...
}:
let
  gitUser = {
    name = "Yurii Luchka";
    email = "yurii@miggo.io";
  };
in
{
  imports = [ ../../modules/home ];

  programs = {
    aerospace.enable = os == "darwin";
    chromium.enable = os == "linux";
    claude-code.enable = true;
    direnv.enable = true;
    gh.enable = true;
    ghostty.enable = true;
    git.enable = true;
    go.enable = true;
    gpg.enable = false;
    mcp.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    btop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    lazygit.enable = true;
    lazydocker.enable = true;
    lazysql.enable = true;
    ripgrep.enable = true;
  };
  workstation.node.enable = true;
  workstation.copilot.enable = true;

  home.packages =
    with pkgs;
    [
      python3
      openssl
      sqlite
      gcc
      clang-tools
      tree-sitter
      luajit
      nixfmt
      uv
      yq
      coreutils
      herdr
    ]
    ++ lib.optionals (os == "darwin") [ cocoapods ];

  # The employer is part of the author identity, not the login/profile name.
  programs.git.settings.user = gitUser // {
    useConfigOnly = true;
  };
  programs.jujutsu.settings.user = gitUser;
}
