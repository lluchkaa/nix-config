{ lib, ... }@inputs: {
  programs.tmux = {
    enable = lib.mkDefault true;
  };
}
