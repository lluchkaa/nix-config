{ pkgs, ... }:
{
  programs.gpg = {
    enable = false;
    settings = {
      default-key = "";
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = false;
    enableSshSupport = true;
  };
}
