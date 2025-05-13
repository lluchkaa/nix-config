{ username, pkgs, ... }@inputs: {
  users.users.${username} = {
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };
}
