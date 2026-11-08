{
  pkgs,
  anthropics-skills,
  matt-pocock-skills,
}:
{
  grilling = "${matt-pocock-skills}/skills/productivity/grilling";
  grill-me = "${matt-pocock-skills}/skills/productivity/grill-me";
  grill-with-docs = "${matt-pocock-skills}/skills/engineering/grill-with-docs";
  # upstream sets disable-model-invocation; strip it so Claude can auto-invoke
  improve-codebase-architecture = pkgs.runCommand "improve-codebase-architecture" { } ''
    cp -rL ${matt-pocock-skills}/skills/engineering/improve-codebase-architecture $out
    chmod -R u+w $out
    sed -i '/^disable-model-invocation:/d' $out/SKILL.md
  '';
  codebase-design = "${matt-pocock-skills}/skills/engineering/codebase-design";
  skill-creator = "${anthropics-skills}/skills/skill-creator";
}
