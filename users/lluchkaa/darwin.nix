{ ... }:
{
  imports = [
    ../../modules/common/nix
    ../../modules/common/pkgs
    ../../modules/common/home
    ../../modules/common/shell
    ../../modules/darwin/core/system
    ../../modules/darwin/core/homebrew

    ../../modules/users/me
  ];
}
