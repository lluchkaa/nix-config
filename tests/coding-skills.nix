{ pkgs, inputs }:
let
  sources = {
    inherit pkgs;
    anthropics-skills = "/sources/anthropics";
    matt-pocock-skills = ./fixtures/coding-skills/matt-pocock;
    superpowers = ./fixtures/coding-skills/superpowers;
  };
  configure =
    tool: extraSources:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = sources // extraSources;
      modules = [
        ../modules/home/core/pkgs/${tool}
        {
          home = {
            username = "test";
            homeDirectory = "/home/test";
            stateVersion = "24.11";
          };
          xdg.configHome = "/home/test/.config";
          programs.${tool}.enable = true;
        }
      ];
    }).config.programs.${tool};
  # Codex receives no Claude configuration or marketplace sources.
  codex = configure "codex" { };
  claude = configure "claude-code" {
    claude-plugins = "/sources/claude-plugins";
    caveman = "/sources/caveman";
    chrome-devtools-mcp = "/sources/chrome-devtools";
    ponytail = "/sources/ponytail";
  };
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
