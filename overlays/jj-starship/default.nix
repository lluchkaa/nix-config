{ jj-starship }:
final: _: {
  jj-starship-no-git = jj-starship.packages.${final.stdenv.hostPlatform.system}.jj-starship-no-git;
}
