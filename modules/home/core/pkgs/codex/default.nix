{
  pkgs,
  anthropics-skills,
  matt-pocock-skills,
  ...
}:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    context = " ";
    skills = import ../coding-skills { inherit pkgs anthropics-skills matt-pocock-skills; };
  };
}
