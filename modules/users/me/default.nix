{ username, os, lib, pkgs, ... }@inputs: {
  users.users.${username} = {
    description = username;

    home = (if os == "darwin" then "/Users/${username}" else "/home/${username}");

    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  } // lib.optionalAttrs (os == "linux") {
    isNormalUser = true;

    extraGroups = lib.mkIf (os == "linux") ["wheel" "networkmanager" "docker"];

    # TODO: convert to hashed password
    initialPassword = "root";
  } // lib.optionalAttrs (os == "darwin") {
    uid = 501;
  };

  programs.fish = {
    enable = true;
  };
}
