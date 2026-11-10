{ config, lib, ... }: {
  config = lib.mkIf config.programs.gpg.enable {
    # TODO: enable + populate default-key once GPG signing key is generated.
    programs.gpg = lib.mkDefault {
      settings = {
        default-key = "";
        use-agent = true;
      };
    };

    services.gpg-agent = {
      enable = lib.mkDefault false;
      enableSshSupport = true;
    };
  };
}
