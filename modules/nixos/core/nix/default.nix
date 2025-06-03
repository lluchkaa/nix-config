{
  username,
  lib,
  pkgs,
  ...
}@inputs: {
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    settings = {
      trusted-users = ["root" "@admin" username];

      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://nix-community.cachix.org"
        "https://lluchkaa.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "lluchkaa.cachix.org-1:OZsJHkBMAfwSUm1gHwqKMA/iaLiyRuC9X90Bp+kX7UI="
      ];
      builders-use-substitutes = lib.mkDefault true;
    };

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nixpkgs.config.allowUnsupportedSystem = lib.mkDefault true;
}
