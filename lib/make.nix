{
  nixpkgs,
  overlays,
  inputs,
}:
{
  name,
  system,
  username,
  os,
}:
let
  inherit (inputs)
    self
    nix-index-database
    ;

  systemFunc = if os == "darwin" then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerFunc =
    if os == "darwin" then
      inputs.home-manager.darwinModules.home-manager
    else
      inputs.home-manager.nixosModules.home-manager;

  hostConfigPath = ../hosts/${name};
  hostConfig = if builtins.pathExists hostConfigPath then hostConfigPath else _: { };
  platformConfig = ../modules/${if os == "darwin" then "darwin" else "nixos"};
in
systemFunc {
  inherit system;

  specialArgs = {
    inherit (inputs) catppuccin nix-homebrew;
    inherit
      self
      username
      os
      system
      ;
  };

  modules = [
    { nixpkgs.overlays = overlays; }

    hostConfig
    platformConfig
    ../modules/users/me
    ../users/${username}/${if os == "darwin" then "darwin" else "nixos"}.nix

    homeManagerFunc
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit username os;
        }
        // inputs;
        users.${username} = {
          imports = [
            ../users/${username}/home.nix
          ];
        };
      };
    }

    (
      if os == "darwin" then
        nix-index-database.darwinModules.nix-index
      else
        nix-index-database.nixosModules.nix-index
    )
  ];
}
