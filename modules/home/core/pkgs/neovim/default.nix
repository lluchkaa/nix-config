{ lib, ... }@inputs: {
  programs.neovim = {
    enable = lib.mkDefault true;
  };
}
