{ username, lib, pkgs, ... }@inputs: {
  users.users.${username} = {
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };
}
