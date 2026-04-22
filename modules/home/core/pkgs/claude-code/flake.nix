{
  description = "Claude Code external plugin sources";

  inputs = {
    claude-plugins = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };

    caveman = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };

    matt-pocock = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    chrome-devtools = {
      url = "github:ChromeDevTools/chrome-devtools-mcp";
      flake = false;
    };
  };

  outputs =
    {
      claude-plugins,
      caveman,
      matt-pocock,
      chrome-devtools,
      ...
    }:
    {
      inherit
        claude-plugins
        caveman
        matt-pocock
        chrome-devtools
        ;
    };
}
