{ ... }@inputs: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      # TODO: do not use root login
      PermitRootLogin = "yes";
    };
    openFirewall = true;
  };
}
