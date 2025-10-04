{
  username,
  os,
  lib,
  ...
}@inputs:
{
  home = {
    inherit username;

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  home.homeDirectory = if os == "darwin" then "/Users/${username}" else "/home/${username}";
}
