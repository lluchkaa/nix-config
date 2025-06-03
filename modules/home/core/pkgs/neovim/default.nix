{ lib, pkgs, ... }@inputs: {
  # programs.neovim = {
  #   enable = lib.mkDefault true;
  # };

  home.packages = [
    pkgs.neovim
  ];

  xdg.configFile = {
    "nvim".source = ./nvim;
  };
}
