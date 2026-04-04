{ os, lib, ... }:
{
  imports = [
    ./i3
  ];

  xresources = lib.mkIf (os == "linux") {
    extraConfig = builtins.readFile ./XResources;
  };
}
