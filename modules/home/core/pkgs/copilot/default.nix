{ pkgs, ... }:
{
  home.packages = [
    pkgs.github-copilot-cli
  ];

  home.shellAliases = {
    "??" = "copilot";
  };
}
