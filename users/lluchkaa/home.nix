{ ... }@inputs: {
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
    userName = "Yura Luchka";
    userEmail = "lluchkaa@gmail.com";
  };
}
