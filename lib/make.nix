{ nixpkgs, overlays, inputs }:
{
  name,
  system,
  username,
  os,
}: let 
  inherit (inputs) self nix-index-database catppuccin stylix;

  systemFunc = if os == "darwin" then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerFunc = if os == "darwin" then inputs.home-manager.darwinModules.home-manager else inputs.home-manager.nixosModules.home-manager;

  hostConfig = ../hosts/${name};
  userOSConfig = ../users/${username}/${if os == "darwin" then "darwin" else "nixos"}.nix;
  userHomeConfig = ../users/${username}/home.nix;
in systemFunc {
  inherit system;

  specialArgs = { inherit self username os system; };

  modules = [
    { nixpkgs.overlays = overlays; }

    hostConfig
    userOSConfig

    homeManagerFunc {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = { inherit username os; };

      home-manager.users.${username} = {
        imports = [
          userHomeConfig

          nix-index-database.homeModules.nix-index
          catppuccin.homeModules.catppuccin
          stylix.homeModules.stylix
        ];
      };
    }

    (if os == "darwin" then nix-index-database.darwinModules.nix-index else nix-index-database.nixosModules.nix-index )
    (if os == "darwin" then {} else catppuccin.nixosModules.catppuccin)
    (if os == "darwin" then stylix.darwinModules.stylix else stylix.nixosModules.stylix)
  ];
}
