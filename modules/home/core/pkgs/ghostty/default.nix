{ os, lib, ... }@inputs: {
  programs.ghostty = {
    enable = lib.mkDefault true;
    settings = {
      font-family = "Monaspace Krypton Var";
      font-variation = "wght=300";
      font-size = 13;

      window-padding-balance = "true";

      title = " ";
      macos-titlebar-proxy-icon = "hidden";
      window-decoration = "server";

      macos-icon = "custom-style";
      macos-icon-frame = "plastic";
      macos-icon-ghost-color = "#F38BA8";
      macos-icon-screen-color = "#1E1E2E";

      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;

      window-colorspace = "display-p3";

      keybind = "cmd+t=unbind";
    }; 
  } // lib.optionalAttrs (os == "darwin") {
    package = null;
  };
}
