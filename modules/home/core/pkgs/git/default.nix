_: {
  programs.git = {
    enable = true;

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
      push = {
        autoSetupRemote = true;
      };
    };

    # rest should be set in users/*/home.nix file
  };
}
