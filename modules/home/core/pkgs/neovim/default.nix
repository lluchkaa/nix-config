{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.neovim.enable {
    programs.neovim = lib.mkDefault {
      extraPackages = [ pkgs.nixd ];
    };

    xdg.configFile.nvim = {
      source = ./nvim;
      recursive = true;
    };
  };
}
