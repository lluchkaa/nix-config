{
  os,
  ...
}:
{
  programs.chromium = {
    enable = os == "linux";
  };
}
