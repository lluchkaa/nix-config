# Coding-skill distribution implementation plan

> Use test-driven development for the single refactor below.

**Goal:** Concentrate coding-skill selection, compatibility, and delivery in the existing module.

**Design:** `coding-skills/default.nix` returns `claude` and `codex` configuration fragments. Claude receives curated skills, its Superpowers marketplace, and plugin enablement; Codex receives curated skills plus valid Superpowers directories. Consumer modules merge these fragments with their own configuration. Preserve the current metadata rewrite and Superpowers precedence on name collisions.

**Scope:** Implement candidate 01 from the architecture report, as requested. Formatter ownership is separate. Work in the existing checkout and leave the pre-existing Homebrew audit untouched. No activation or deployment.

**Alternatives:** Repairing only the test fixture leaves discovery knowledge in Codex. A new generic plugin framework adds indirection without another consumer. Deepen the existing coding-skills module instead.

**Test surface:** Resulting Claude and Codex configuration, plus the generated skill directory. Local fixtures represent upstream source trees; use real Nix transformations and build the metadata rewrite.

## Task 1: Deepen distribution and repair regression coverage

- [x] Add consumer-configuration checks for curated skills, independent Codex discovery, invalid entries, collision precedence, Claude marketplace/enablement, and preservation of unrelated settings.
- [x] Add a build check for metadata removal, retained content, and copied supporting resources.
- [x] Run the checks against the current code and observe the existing missing-Superpowers regression or missing distribution output.
- [x] Move source discovery and Superpowers delivery into `coding-skills/default.nix`; merge its fragments in the two consumers.
- [x] Remove skill assertions from the unrelated language-support test; register focused coding-skill checks.
- [x] Run focused checks, the flake checks, and formatting/lint checks; review the complete diff.

## Verification record

- RED: focused evaluation failed because the original catalog did not accept `superpowers` or expose consumer fragments.
- GREEN: focused evaluation passed; the generated skill artifact built and matched expected metadata, content, and supporting resources.
- `nix flake check --offline path:/Users/lluchkaa/projects/nix-config` passed on aarch64-darwin: both check derivations, including the existing Neovim checks, 9 project-session tests, and 6 Node runtime tests. Incompatible Linux checks were omitted by Nix.
- `nixfmt --check` for all six changed/new Nix files and `git diff --check` passed.
- Fresh-context review found no blockers. Added assertions for the remaining curated skills after its coverage observation.
- Statix and Deadnix could not be completed with cached tools; their uncached toolchain rebuilds were not allowed to continue.

## Review focus

- Claude's native plugin delivery must not also install Superpowers as individual directories.
- Codex must reject source entries without a skill file and preserve existing collision precedence.
- Consumer settings and unrelated marketplaces must survive configuration merging.
- Compatibility rewriting must copy supporting resources and retain skill content.
- Local test sources must require neither a network connection nor Claude configuration for Codex.
