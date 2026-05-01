{ ... }:
{
  # Register zsh in /etc/shells, set ZDOTDIR via /etc/zshenv,
  # and skip macOS global compinit so home-manager runs it once.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
  };
}
