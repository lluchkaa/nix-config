{
  username,
  os,
  lib,
  pkgs,
  ...
}:
{
  users.users.${username} = {
    description = username;

    home = (if os == "darwin" then "/Users/${username}" else "/home/${username}");

    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  }
  // lib.optionalAttrs (os == "linux") {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];

    hashedPassword = "$6$br4rEN6o70zzfx0k$X5pX.LR3.KK8j5FmT./gEoq6SroEMEmjJcLVUDsTT3LsZM5k82l4ZJ4SZYkEThdSlVjaEpIEPTgDolgL8vLQ01";
  }
  // lib.optionalAttrs (os == "darwin") {
    uid = 501;
  };

  programs.fish = {
    enable = true;
  };
}
