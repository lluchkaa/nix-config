{pkgs, ...}@inputs: {
  home.pointerCursor = {
    enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
  };
}
