{ nixpkgs, overlays, inputs }:
{
  name,
  system,
  username,
  os,
}: let 
  systemFunc = nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules.home-manager;

  hostConfig = ../hosts/${name};
  userOSConfig = ../users/${username}/nixos.nix;
  userHomeConfig = ../users/${username}/home.nix;

  inherit (inputs) nix-index-database catppuccin stylix;
in systemFunc {
  inherit system;

  specialArgs = { inherit username os; };

  modules = [
    { nixpkgs.overlays = overlays; }

    hostConfig

    userOSConfig

    home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = { inherit username os; };

      home-manager.users.${username} = {
        imports = [
          userHomeConfig

          nix-index-database.hmModules.nix-index
          catppuccin.homeModules.catppuccin
          stylix.nixosModules.stylix
        ];
      };
    }

    (if os == "linux" then nix-index-database.nixosModules.nix-index else {})
    (if os == "linux" then catppuccin.nixosModules.catppuccin else {})
    (if os == "linux" then stylix.nixosModules.stylix else {})

    (if os == "darwin" then nix-index-database.darwinModules.nix-index else {})
    (if os == "darwin" then stylix.darwinModules.stylix else {})
  ];
}
