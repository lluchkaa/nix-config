{
  description = "Nix and NixOS system and tools by lluchkaa";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    make = import ./lib/make.nix {
      inherit nixpkgs inputs;
    };
  in {
    nixosConfigurations.vm-aarch64 = make {
      name = "vm-aarch64";
      system = "aarch64-linux";
      username = "lluchkaa";
    };
  };
}
