{ lib, config, ... }: {
  config = lib.mkIf config.programs.go.enable {
    programs.go = lib.mkDefault {
      env.GOPATH = "${config.home.homeDirectory}/.local/share/go";
    };
  };
}
