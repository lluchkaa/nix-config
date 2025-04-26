{ nixpkgs, inputs }: 
{
  name,
  system,
  username,
}: let 
  systemFunc = nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules.home-manager;

  hostConfig = ../hosts/${name};
  userOSConfig = ../users/${username}/nixos.nix;
  userHomeConfig = ../users/${username}/home.nix;
in systemFunc {
  inherit system;

  specialArgs = { inherit username; };

  modules = [
    hostConfig

    userOSConfig

    home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = { inherit username; };

      home-manager.users.${username} = import userHomeConfig;
    }
  ];
}
