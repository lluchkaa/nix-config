{ ... }@inputs:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        editor = "vim";
        diff-editor = "vimdiff";
      };
    };
  };
}
