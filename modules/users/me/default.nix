{
  username,
  os,
  lib,
  pkgs,
  ...
}:
{
  users.users.${username} = {
    description = lib.mkDefault username;

    home = lib.mkDefault (if os == "darwin" then "/Users/${username}" else "/home/${username}");

    # Override the NixOS default shell while allowing account-specific choices.
    shell = lib.mkOverride 900 pkgs.zsh;
  }
  // lib.optionalAttrs (os == "linux") {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];

  };

  programs.fish = {
    enable = true;
  };
}
