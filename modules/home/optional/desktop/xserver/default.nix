{ ... }@inputs: {
  imports = [
    ./i3
  ];

  xresources.extraConfig = builtins.readFile ./XResources;
}
