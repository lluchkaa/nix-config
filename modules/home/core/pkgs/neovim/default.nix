{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    extraPackages = [ pkgs.nixd ];
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
}
