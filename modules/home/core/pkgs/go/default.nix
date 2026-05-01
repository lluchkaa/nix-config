{ ... }:
{
  programs.go = {
    enable = true;
    env.GOPATH = ".local/share/go";
  };
}
