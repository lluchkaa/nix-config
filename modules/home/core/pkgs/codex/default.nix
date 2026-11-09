{
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
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    context = " ";
  }
  // codingSkills.codex;
}
