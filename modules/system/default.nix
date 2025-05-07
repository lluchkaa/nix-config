{
  username,
  lib,
  pkgs,
  ...
}@inputs: {
  imports = [
    ./packages.nix
    ./user.nix
  ];

  system.stateVersion = "25.05";

  nix.settings = {
    trusted-users = [username];

    experimental-features = ["nix-command" "flakes"];

    substituters = [
      "https://nix-community.cachix.org"
      "https://lluchkaa.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lluchkaa.cachix.org-1:OZsJHkBMAfwSUm1gHwqKMA/iaLiyRuC9X90Bp+kX7UI="
    ];
    builders-use-substitutes = true;
  };

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nix.package = pkgs.nixVersions.latest;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  time.timeZone = "Europe/Kyiv";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      # TODO: do not use root login
      PermitRootLogin = "yes";
    };
    openFirewall = true;
  };
}
