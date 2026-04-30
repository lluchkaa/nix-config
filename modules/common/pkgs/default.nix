{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.cachix
    pkgs.fish
  ];
}
