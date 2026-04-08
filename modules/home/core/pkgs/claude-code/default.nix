{ pkgs, config, ... }:
{
  home.packages = [ pkgs.terminal-notifier ];

  programs.claude-code = {
    enable = true;
    hooks = {
      "notify.sh" = ''
        #!/bin/bash
        TITLE="$1"
        MESSAGE="$2"

        if [ "$TERM_PROGRAM" = "ghostty" ]; then
          APP="com.mitchellh.ghostty"
        elif [ "$TERM_PROGRAM" = "vscode" ]; then
          APP="com.microsoft.VSCode"
        elif [ "$TERM_PROGRAM" = "WezTerm" ]; then
          APP="com.github.wez.wezterm"
        elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
          APP="com.googlecode.iterm2"
        else
          APP="com.apple.Terminal"
          PID=$$
          for _ in $(seq 1 10); do
            PID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
            [ -z "$PID" ] || [ "$PID" -le 1 ] && break
            PROC=$(ps -p "$PID" -o comm= 2>/dev/null | xargs basename 2>/dev/null)
            case "$PROC" in
              *Code*)       APP="com.microsoft.VSCode";   break ;;
              *wezterm*)    APP="com.github.wez.wezterm"; break ;;
              *iTerm*)      APP="com.googlecode.iterm2";  break ;;
              *Warp*)       APP="dev.warp.Warp-Stable";   break ;;
              *Alacritty*)  APP="io.alacritty";           break ;;
              *kitty*)      APP="net.kovidgoyal.kitty";   break ;;
              *ghostty*)    APP="com.mitchellh.ghostty";  break ;;
            esac
          done
        fi

        ICON="${config.xdg.dataHome}/icons/claude.png"

        terminal-notifier -title "$TITLE" -message "$MESSAGE" -activate "$APP" -appIcon "$ICON"
      '';
    };
    settings = {
      hooks = {
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "bash $HOME/.claude/hooks/notify.sh \"Claude Code\" \"Claude needs your attention\"";
              }
            ];
          }
        ];
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "bash $HOME/.claude/hooks/notify.sh \"Claude Code\" \"Task completed\"";
              }
            ];
          }
        ];
      };
    };
  };
}
