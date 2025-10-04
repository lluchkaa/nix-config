{ lib, ... }@inputs: {
  programs.git = {
    enable = true;

    ignores = [".DS_Store" ".ignore/"];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        ignorecase = false;
      };
    };

    # rest should be set in users/*/home.nix file
  };
}
