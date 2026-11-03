{ config, ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    context = " ";
    # Same skills as Claude Code; Codex has no LSP support, so lsps.nix is not shared.
    skills = config.programs.claude-code.skills;
  };
}
