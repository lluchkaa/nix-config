{ config, ... }@inputs: {
  home.preferXdgDirectories = true;

  xresources.extraConfig = builtins.readFile ./XResources;
}

