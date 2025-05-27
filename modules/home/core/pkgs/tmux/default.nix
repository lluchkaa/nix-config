{ lib, pkgs, ... }@inputs: {
  programs.tmux = {
    enable = lib.mkDefault true;
  };

  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ./tmux-sessionizer))
  ];

  home.shellAliases = {
    ts = "tmux-sessionizer";
  };
}
