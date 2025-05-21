{ os, lib, pkgs, ... }@inputs: {
  imports = [
    ./ghostty
    ./neovim
    ./tmux
    ./gh
  ];

  home.packages = [
    pkgs.rustup
    pkgs.zig
    pkgs.ocaml
    pkgs.nodejs

    pkgs.sqlite
    pkgs.gcc

    pkgs.yq
  ];

  programs.git = {
    enable = lib.mkDefault true;

    ignores = [".DS_Store"];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        ignorecase = true;
      };
    };

    # rest should be set in users/*/home.nix file
  };

  programs.direnv = {
    enable = lib.mkDefault true;
  };

  programs.go = {
    enable = lib.mkDefault true;
    goPath = "dev/go";
  };

  programs.fzf = {
    enable = lib.mkDefault true;
  };

  programs.ripgrep = {
    enable = lib.mkDefault true;
  };

  programs.jq = {
    enable = lib.mkDefault true;
  };

  programs.btop = {
    enable = lib.mkDefault true;
  };

  programs.gh = {
    enable = lib.mkDefault true;
  };

  programs.lazygit = {
    enable = lib.mkDefault true;
  };

  programs.lazydocker = {
    enable = lib.mkDefault true;
  };
}
