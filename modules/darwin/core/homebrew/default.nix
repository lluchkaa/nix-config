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

  # Workaround for nix-homebrew#189: its brew wrapper drops the HOMEBREW_PATH restore on re-exec, so
  # auto-update inside `brew bundle` loses /opt/homebrew/bin and masApps fail. Update here, outside
  # the bundle, and keep onActivation.autoUpdate off. Drop once the wrapper is fixed upstream.
  system.activationScripts.preActivation.text = ''
    sudo --user=${username} --set-home /opt/homebrew/bin/brew update || echo "brew update failed, continuing" >&2
  '';

  homebrew = {
    enable = true;
    onActivation = {
      # Off: nix-homebrew#189 nix-homebrew#149 nix-homebrew#131, brew's auto-update re-exec loses /opt/homebrew/bin
      # from PATH, which breaks masApps. Casks still upgrade via `upgrade = true`.
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
