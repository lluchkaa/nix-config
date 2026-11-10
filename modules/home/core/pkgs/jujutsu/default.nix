{ config, lib, ... }: {
  config = lib.mkIf config.programs.jujutsu.enable {
    programs.jujutsu = lib.mkDefault {
      settings = {
        ui = {
          editor = "vim";
          diff-editor = "vimdiff";
        };
      };
    };
  };
}
