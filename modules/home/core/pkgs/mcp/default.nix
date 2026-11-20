_: {
  programs.mcp = {
    enable = true;
    servers.superlogical = {
      type = "http";
      url = "https://www.superlogical.com/rex/community-mcp";
    };
  };
}
