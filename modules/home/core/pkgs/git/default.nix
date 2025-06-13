{ lib, ... }@inputs: {
  programs.git = {
    enable = true;

    ignores = [".DS_Store"];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        ignorecase = true;
      };
    };

    # rest should be set in users/*/home.nix file
  };
}
