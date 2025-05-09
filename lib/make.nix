{ nixpkgs, overlays, inputs }:
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

  catppuccin = inputs.catppuccin;
in systemFunc {
  inherit system;

  specialArgs = { inherit username; };

  modules = [
    { nixpkgs.overlays = overlays; }

    hostConfig

    userOSConfig

    home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = { inherit username; };

      home-manager.users.${username} = {
        imports = [
          userHomeConfig
          catppuccin.homeModules.catppuccin
        ];
      };
    }

    catppuccin.nixosModules.catppuccin
  ];
}
