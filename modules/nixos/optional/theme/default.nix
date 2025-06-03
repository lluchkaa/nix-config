{ pkgs, ... }@inputs: {
  catppuccin = {
    enable = true;
  };

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
