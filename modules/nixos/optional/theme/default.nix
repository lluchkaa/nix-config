{ lib, ... }@inputs: {
  catppuccin = {
    enable = lib.mkDefault true;
  };
}
