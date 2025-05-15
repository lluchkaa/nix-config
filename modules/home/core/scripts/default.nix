{ pkgs, ... }@inputs: {
  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ./tmux-sessionizer))
  ];

  home.shellAliases = {
    ts = "tmux-sessionizer";
  };
}
