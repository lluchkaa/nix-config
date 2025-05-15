{ ... }@inputs: {
  imports = [
    ./i18n
    ./ssh
    ./time
  ];

  system.stateVersion = "25.05";

  security.sudo.wheelNeedsPassword = false;
}
