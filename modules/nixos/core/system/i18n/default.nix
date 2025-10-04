{ pkgs, ... }@inputs:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = [
        pkgs.fcitx5-gtk
        pkgs.fcitx5-hangul
      ];
    };
  };
}
