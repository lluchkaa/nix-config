{ username, ... }@inputs: {
  home = {
    inherit username;

    stateVersion = "24.11";

    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;

    cava.enable = false;
    gh-dash.enable = false;
    imv.enable = false;
    swaylock.enable = false;
    mako.enable = false;
  };
}
