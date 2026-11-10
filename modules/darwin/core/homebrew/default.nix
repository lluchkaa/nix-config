{
  nix-homebrew,
  username,
  ...
}:
let
  selection = import ../../../../users/${username}/homebrew;
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
    inherit (selection) brews masApps;
    casks = map (name: {
      inherit name;
      greedy = true;
    }) selection.casks;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
