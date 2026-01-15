{ ... }@inputs:
{
  programs.git = {
    enable = true;

    ignores = [
      ".DS_Store"
      ".ignore/"
      ".worktrees/"
      ".direnv/"
    ];

    settings = {
      init = {
        defaultBranch = "main";
      };
      core = {
        ignorecase = false;
      };
      push = {
        autoSetupRemote = true;
      };
    };

    # rest should be set in users/*/home.nix file
  };
}
