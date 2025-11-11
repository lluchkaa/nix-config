{ ... }@inputs:
{
  imports = [
    ../../modules/home/core
    ../../modules/home/core/pkgs
    ../../modules/home/core/shell
    ../../modules/home/core/xdg
    ../../modules/home/core/apps

    ../../modules/home/optional/desktop/xserver
    ../../modules/home/optional/theme
  ];

  programs.git = {
    settings = {
      user = {
        name = "Yura Luchka";
        email = "lluchkaa@gmail.com";
      };
    };
  };

  programs.jujutsu = {
    settings = {
      user = {
        name = "Yura Luchka";
        email = "lluchkaa@gmail.com";
      };
    };
  };
}
