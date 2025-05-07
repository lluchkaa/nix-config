{ username, pkgs, ... }@inputs: {
  imports = [
    ../../modules/i3
  ];

  users.users.${username} = {
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };
}
