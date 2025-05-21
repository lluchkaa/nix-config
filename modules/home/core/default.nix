{ username, os, lib, ... }@inputs: {
  home = {
    inherit username;

    stateVersion = "24.11";
  };

  programs.home-manager.enable = lib.mkDefault true;
}
