{
  username,
  lib,
  pkgs,
  ...
}@inputs: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["wheel" "networkmanager" "docker"];

    # TODO: convert to hashed password
    initialPassword = "root";
  };
}
