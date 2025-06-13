{ lib, pkgs, ... }@inputs: {
  programs.gh = {
    enable = true;

    extensions = [
      pkgs.gh-copilot
    ];
  };

  home.shellAliases = {
    "??" = "gh copilot suggest -t shell";
  };
}
