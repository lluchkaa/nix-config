{ config, lib, ... }: {
  config = lib.mkIf config.programs.direnv.enable {
    programs.direnv = lib.mkDefault {
      config = {
        disable_stdin = true;
      };
      nix-direnv.enable = true;
    };
  };
}
