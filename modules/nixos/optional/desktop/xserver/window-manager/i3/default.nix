{ ... }@inputs: {
  services.xserver.windowManager = {
    i3 = {
      enable = true;
    };
  };

  services.gvfs.enable = true;
}
