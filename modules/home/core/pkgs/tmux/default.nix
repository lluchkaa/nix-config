{ lib, pkgs, ... }@inputs: {
  imports = [
    ./gitmux
  ];

  # programs.tmux = {
  #   enable = lib.mkDefault true;
  # };

  home.packages = [
    pkgs.tmux
    (pkgs.writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ./tmux-sessionizer))
  ];

  home.shellAliases = {
    ts = "tmux-sessionizer";
  };
}
