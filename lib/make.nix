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
  usernames ? [ username ],
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
      usernames
      os
      system
      ;
  };

  modules = [
    { nixpkgs.overlays = overlays; }

    hostConfig
    platformConfig
    {
      assertions = [
        {
          assertion = builtins.elem username usernames;
          message = "The primary user must be included in usernames.";
        }
        {
          assertion = builtins.length usernames == builtins.length (nixpkgs.lib.unique usernames);
          message = "Usernames must be unique.";
        }
      ];
    }
    {
      imports = nixpkgs.lib.concatMap (user: [
        (
          { lib, pkgs, ... }:
          import ../modules/users/me {
            inherit lib pkgs os;
            username = user;
          }
        )
        ../users/${user}/${if os == "darwin" then "darwin" else "nixos"}.nix
      ]) usernames;
    }

    homeManagerFunc
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit os;
        }
        // inputs;
        users = nixpkgs.lib.genAttrs usernames (user: {
          _module.args.username = user;
          imports = [
            ../users/${user}/home.nix
          ];
        });
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
