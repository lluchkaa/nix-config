{ lib, pkgs, ... }@inputs: {
  programs.neovim = {
    enable = lib.mkDefault true;
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
}
