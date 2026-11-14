{
  nix-homebrew,
  username,
  ...
}:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
    ./brews
    ./casks
    ./mas
  ];

  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      # Off: nix-homebrew#189, brew's auto-update re-exec loses /opt/homebrew/bin
      # from PATH, which breaks masApps. Casks still upgrade via `upgrade = true`.
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
