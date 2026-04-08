{
  username,
  os,
  ...
}:
{
  home = {
    inherit username;

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  home.homeDirectory = if os == "darwin" then "/Users/${username}" else "/home/${username}";
}
