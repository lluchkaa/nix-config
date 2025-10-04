{ ... }@inputs:
{
  services.xserver.displayManager = {
    gdm = {
      enable = true;
      wayland = false;
    };
  };
}
