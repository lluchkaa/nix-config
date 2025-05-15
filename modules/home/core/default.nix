{ username, lib, ... }@inputs: {
  home = {
    inherit username;

    stateVersion = "24.11";

    homeDirectory = lib.mkDefault "/home/${username}";
  };

  programs.home-manager.enable = lib.mkDefault true;
}
