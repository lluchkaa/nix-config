{
  pkgs,
  ...
}@inputs: {
  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.gcc
  ];
}
