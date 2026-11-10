{ config, lib, ... }: {
  config = lib.mkIf config.programs.git.enable {
    programs.git = lib.mkDefault {

      signing.format = null;

      ignores = [
        ".DS_Store"
        ".ignore/"
        ".worktrees/"
        ".direnv/"
        ".venv/"
        "node_modules/"
        "*.local.*"
        "*.bak"
      ];

      settings = {
        init = {
          defaultBranch = "main";
        };
        core = {
          ignorecase = false;
        };
        fetch = {
          prune = true;
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
        rebase = {
          autoStash = true;
        };
        rerere = {
          enabled = true;
        };
      };

      # rest should be set in users/*/home.nix file
    };
  };
}
