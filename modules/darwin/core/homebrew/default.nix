{
  lib,
  nix-homebrew,
  username,
  usernames,
  ...
}:
let
  selections = map (user: import ../../../../users/${user}/homebrew) usernames;
  brews = lib.unique (lib.concatMap (selection: selection.brews) selections);
  casks = lib.unique (lib.concatMap (selection: selection.casks) selections);
in
{
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    user = username;
    inherit brews;
    casks = map (name: {
      inherit name;
      greedy = true;
    }) casks;
    masApps = lib.mkMerge (map (selection: selection.masApps) selections);
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
