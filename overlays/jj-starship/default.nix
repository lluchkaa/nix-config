{ jj-starship }:
final: _: {
  inherit (jj-starship.packages.${final.stdenv.hostPlatform.system}) jj-starship-no-git;
}
