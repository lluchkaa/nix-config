{
  pkgs,
  anthropics-skills,
  matt-pocock-skills,
  superpowers,
  ...
}:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    context = " ";
    skills = (import ../coding-skills { inherit pkgs anthropics-skills matt-pocock-skills; })
      // pkgs.lib.mapAttrs (name: _: "${superpowers}/skills/${name}") (
        pkgs.lib.filterAttrs (
          name: type: type == "directory" && builtins.pathExists "${superpowers}/skills/${name}/SKILL.md"
        ) (builtins.readDir "${superpowers}/skills")
      );
  };
}
