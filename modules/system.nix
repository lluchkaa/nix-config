{
  username,
  lib,
  pkgs,
  ...
}@inputs: {
  system.stateVersion = "25.05";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["wheel" "docker"];

    # TODO: convert to hashed password
    initialPassword = "root";
  };

  nix.settings = {
    trusted-users = [username];

    experimental-features = ["nix-command" "flakes"];

    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  time.timeZone = "Europe/Kyiv";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.git
  ];
}
