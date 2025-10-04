{ ... }@inputs:
{
  imports = [
    ./brews
    ./casks
    ./mas
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
  };
}
