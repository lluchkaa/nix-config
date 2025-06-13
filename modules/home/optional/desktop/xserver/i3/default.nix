{ os, lib, ... }@inputs: {
  programs.i3status = {
    enable = os == "linux";

    general = {
      colors = true;
      color_good = "#f5e0dc";
      color_bad = "#f38ba8";
      color_degraded = "#f9e2af";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "ethernet _first_".enable = false;
      "disk /".enable = false;
    };
  };

  xdg.configFile = {
    "i3/config".source = ./i3;
  };
}
