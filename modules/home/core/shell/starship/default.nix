{ lib, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;

    enableTransience = true;
    settings = lib.importTOML ./starship.toml;
  };

  home.packages = [
    pkgs.jj-starship-no-git
  ];

  # starship prompt reads from stdin and hangs in nested shells (VS Code, tmux,
  # ghostty) where stdin is an inherited pipe. Override PROMPT/RPROMPT to
  # redirect stdin to /dev/null. PROMPT2 runs $(starship prompt) synchronously
  # at startup — replace with a static string.
  # mkOrder 2000 ensures this runs after starship's own initContent (no mkOrder
  # = default 1000).
  programs.zsh.initContent = lib.mkOrder 2000 ''
    if [[ $TERM != "dumb" ]]; then
      # Patch out PROMPT2 before eval: starship prompt --continuation reads
      # stdin synchronously at startup, hanging in VS Code / tmux / ghostty.
      # PROMPT/RPROMPT use wrapper functions that redirect stdin to /dev/null.
      eval "$(starship init zsh </dev/null | sed 's/PROMPT2=.*/PROMPT2="> "/')"
      __starship_prompt() {
        starship prompt --terminal-width="$COLUMNS" --keymap="''${KEYMAP:-}" \
          --status="''${STARSHIP_CMD_STATUS:-}" --pipestatus="''${STARSHIP_PIPE_STATUS[*]:-}" \
          --cmd-duration="''${STARSHIP_DURATION:-}" --jobs="''${STARSHIP_JOBS_COUNT:-}" \
          </dev/null
      }
      __starship_rprompt() {
        starship prompt --right --terminal-width="$COLUMNS" --keymap="''${KEYMAP:-}" \
          --status="''${STARSHIP_CMD_STATUS:-}" --pipestatus="''${STARSHIP_PIPE_STATUS[*]:-}" \
          --cmd-duration="''${STARSHIP_DURATION:-}" --jobs="''${STARSHIP_JOBS_COUNT:-}" \
          </dev/null
      }
      PROMPT='$(__starship_prompt)'
      RPROMPT='$(__starship_rprompt)'
    fi
  '';
}
