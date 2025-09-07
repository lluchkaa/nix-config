{ pkgs, ... }@inputs: {
  imports = [
    ./fonts
  ];

  catppuccin = {
    enable = true;
  };

  # stylix = {
  #   enable = false;
  #   autoEnable = true;
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  # };
}
