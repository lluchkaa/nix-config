{ pkgs, ... }@inputs: {
  catppuccin = {
    enable = true;
  };

  # stylix = {
  #   enable = false;
  #   autoEnable = false;
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  # };
}
