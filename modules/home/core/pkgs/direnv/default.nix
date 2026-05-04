{ ... }:
{
  programs.direnv = {
    enable = true;
    config = {
      disable_stdin = true;
    };
    nix-direnv.enable = true;
  };
}
