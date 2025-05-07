{ username, ... }@inputs: {
  home = {
    inherit username;

    stateVersion = "24.11";

    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;

  catppuccin.enable = true;
  catppuccin.mako.enable = false;
  catppuccin.gtk.enable = true;
}
