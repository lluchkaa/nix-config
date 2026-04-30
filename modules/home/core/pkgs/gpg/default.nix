{ pkgs, ... }:
{
  # TODO: enable + populate default-key once GPG signing key is generated.
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
