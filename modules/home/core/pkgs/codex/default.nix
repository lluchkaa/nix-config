{
  lib,
  config,
  pkgs,
  anthropics-skills,
  matt-pocock-skills,
  superpowers,
  ...
}:
let
  codingSkills = import ../coding-skills {
    inherit
      pkgs
      anthropics-skills
      matt-pocock-skills
      superpowers
      ;
  };
in
{
  config = lib.mkIf config.programs.codex.enable {
    programs.codex = lib.mkDefault (
      {
        enableMcpIntegration = true;
        context = " ";
      }
      // codingSkills.codex
    );
  };
}
