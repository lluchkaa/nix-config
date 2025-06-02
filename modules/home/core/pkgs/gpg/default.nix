{ lib, ... }@inputs: {
  programs.gpg = {
    enable = lib.mkDefault true;
  };
}
