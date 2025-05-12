self: super: {
  dmenu = super.dmenu.override {
    conf = ./config.h;
  };
}
