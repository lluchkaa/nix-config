{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.workstation.copilot.enable = lib.mkEnableOption "copilot tooling";
  config = lib.mkIf config.workstation.copilot.enable {
    home.packages = [
      pkgs.github-copilot-cli
    ];
  };
}
