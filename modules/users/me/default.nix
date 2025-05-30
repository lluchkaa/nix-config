{ username, os, lib, pkgs, ... }@inputs: {
  users.users.${username} = {
    description = username;

    home = lib.mkDefault (if os == "darwin" then "/Users/${username}" else "/home/${username}");

    uid = 501;
    shell = lib.mkDefault pkgs.fish;
    ignoreShellProgramCheck = true;
  } // lib.optionalAttrs (os == "linux") {
    isNormalUser = true;

    extraGroups = lib.mkIf (os == "linux") ["wheel" "networkmanager" "docker"];

    # TODO: convert to hashed password
    initialPassword = "root";
  };

  users.knownUsers = [username];

  programs.fish = {
    enable = true;
  };
}
