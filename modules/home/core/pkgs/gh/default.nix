{ lib, pkgs, ... }@inputs: {
  programs.gh = {
    enable = lib.mkDefault true;

    extensions = [
      pkgs.gh-copilot
    ];
  };

  home.shellAliases = {
    "??" = "gh copilot suggest -t shell";
  };
}
