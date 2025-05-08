{ username, pkgs, ... }@inputs: {
  imports = [
    ../../modules/i3/nixos.nix
    ../../modules/theme/nixos.nix
  ];

  users.users.${username} = {
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };
}
