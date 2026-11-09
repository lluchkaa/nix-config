{ pkgs }:
let
  inherit (pkgs) lib;
  sources = {
    inherit pkgs;
    anthropics-skills = "/sources/anthropics";
    matt-pocock-skills = ./fixtures/coding-skills/matt-pocock;
    superpowers = ./fixtures/coding-skills/superpowers;
  };
  # Codex receives no Claude configuration or marketplace sources.
  codex = (import ../modules/home/core/pkgs/codex sources).programs.codex;
  claude =
    (import ../modules/home/core/pkgs/claude-code (
      sources
      // {
        inherit lib;
        config.xdg.configHome = "/home/test/.config";
        claude-plugins = "/sources/claude-plugins";
        caveman = "/sources/caveman";
        chrome-devtools-mcp = "/sources/chrome-devtools";
        ponytail = "/sources/ponytail";
      }
    )).programs.claude-code;
  transformed = claude.skills.improve-codebase-architecture;
in
# Exercise the distribution through the configurations its callers consume.
assert claude.skills.grilling == "${sources.matt-pocock-skills}/skills/productivity/grilling";
assert codex.skills.grilling == "${sources.superpowers}/skills/grilling";
assert codex.skills.using-superpowers == "${sources.superpowers}/skills/using-superpowers";
assert !(codex.skills ? not-a-skill);
assert !(codex.skills ? "README.md");
assert !(claude.skills ? using-superpowers);
assert claude.skills.skill-creator == "/sources/anthropics/skills/skill-creator";
assert codex.skills.skill-creator == "/sources/anthropics/skills/skill-creator";
assert claude.skills.grill-me == "${sources.matt-pocock-skills}/skills/productivity/grill-me";
assert codex.skills.grill-me == "${sources.matt-pocock-skills}/skills/productivity/grill-me";
assert
  claude.skills.grill-with-docs == "${sources.matt-pocock-skills}/skills/engineering/grill-with-docs";
assert
  codex.skills.grill-with-docs == "${sources.matt-pocock-skills}/skills/engineering/grill-with-docs";
assert
  claude.skills.codebase-design == "${sources.matt-pocock-skills}/skills/engineering/codebase-design";
assert
  codex.skills.codebase-design == "${sources.matt-pocock-skills}/skills/engineering/codebase-design";
assert claude.marketplaces.superpowers-dev == sources.superpowers;
assert claude.settings.enabledPlugins."superpowers@superpowers-dev";
assert claude.marketplaces.claude-plugins == "/sources/claude-plugins";
assert claude.settings.enabledPlugins."ponytail@ponytail";
assert claude.settings.model == "sonnet";
assert claude.configDir == "/home/test/.config/claude";
assert codex.enable && codex.enableMcpIntegration;
assert codex.skills.improve-codebase-architecture == transformed;
pkgs.runCommand "coding-skill-distribution-checks" { } ''
  cat > expected.md <<'EOF'
  ---
  name: improve-codebase-architecture
  description: Metadata compatibility fixture.
  ---

  # Architecture review fixture

  Keep this skill content and its supporting resource.
  EOF
  diff -u expected.md ${transformed}/SKILL.md
  cmp ${sources.matt-pocock-skills}/skills/engineering/improve-codebase-architecture/HTML-REPORT.md ${transformed}/HTML-REPORT.md
  touch "$out"
''
