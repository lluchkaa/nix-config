{ ... }@inputs: {
  imports = [
    ../../modules/core/home/home.nix
    ../../modules/core/shell/home.nix
    ../../modules/core/xdg/home.nix
    ../../modules/xserver/home.nix
    ../../modules/programs/home.nix
    ../../modules/styles/home.nix
  ];

  programs.git = {
    userName = "Yura Luchka";
    userEmail = "lluchkaa@gmail.com";
  };
}
