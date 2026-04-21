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
  };

  outputs =
    {
      claude-plugins,
      caveman,
      matt-pocock,
      ...
    }:
    {
      inherit claude-plugins caveman matt-pocock;
    };
}
