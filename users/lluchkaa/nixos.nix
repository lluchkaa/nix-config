{ username, pkgs, ... }@inputs: {
  users.users.${username} = {
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
}
