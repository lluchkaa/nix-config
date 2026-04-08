{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.typescript-language-server
    pkgs.gopls
    pkgs.vscode-langservers-extracted
  ];

  programs.claude-code = {
    enable = true;
    hooks = {
      "notify.sh" = ''
        #!/bin/bash
        TITLE="$1"
        MESSAGE="$2"

        find_app() {
          local PID=$1 i=0
          [ -z "$PID" ] && return
          while [ $i -lt 15 ]; do
            i=$((i + 1))
            PID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
            if [ -z "$PID" ] || [ "$PID" -le 1 ]; then break; fi
            PROC=$(ps -p "$PID" -o comm= 2>/dev/null | xargs basename 2>/dev/null)
            case "$PROC" in
              *Code*)       echo "com.microsoft.VSCode";   return ;;
              *wezterm*)    echo "com.github.wez.wezterm"; return ;;
              *iTerm*)      echo "com.googlecode.iterm2";  return ;;
              *Warp*)       echo "dev.warp.Warp-Stable";   return ;;
              *Alacritty*)  echo "io.alacritty";           return ;;
              *kitty*)      echo "net.kovidgoyal.kitty";   return ;;
              *ghostty*)    echo "com.mitchellh.ghostty";  return ;;
            esac
          done
        }

        APP="com.apple.Terminal"
        TMUX_SOCKET=""
        TMUX_CLIENT=""
        TMUX_TARGET=""

        if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
          TMUX_SOCKET="''${TMUX%%,*}"
        fi

        if [ "$TERM_PROGRAM" = "ghostty" ]; then
          APP="com.mitchellh.ghostty"
        elif [ "$TERM_PROGRAM" = "vscode" ]; then
          APP="com.microsoft.VSCode"
        elif [ "$TERM_PROGRAM" = "WezTerm" ]; then
          APP="com.github.wez.wezterm"
        elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
          APP="com.googlecode.iterm2"
        elif [ -n "$TMUX_SOCKET" ]; then
          while IFS='|' read -r client_name client_pid; do
            FOUND=$(find_app "$client_pid")
            if [ -n "$FOUND" ]; then
              APP="$FOUND"
              TMUX_CLIENT="$client_name"
              break
            fi
          done < <(tmux -S "$TMUX_SOCKET" list-clients -F '#{client_name}|#{client_pid}' 2>/dev/null)
        else
          FOUND=$(find_app $$)
          [ -n "$FOUND" ] && APP="$FOUND"
        fi

        if [ -n "$TMUX_SOCKET" ]; then
          TMUX_TARGET=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
          # TMUX_CLIENT already set in the loop above if in tmux; fall back to display-message for non-tmux APP detection paths
          if [ -z "$TMUX_CLIENT" ]; then
            TMUX_CLIENT=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_PANE" -p '#{client_name}' 2>/dev/null)
          fi
        fi

        ICON="${config.xdg.dataHome}/icons/claude.png"

        (
          RESULT=$(alerter --title "$TITLE" --message "$MESSAGE" --app-icon "$ICON" --actions "Open" --timeout 60 --json)
          ACTION=$(echo "$RESULT" | grep -oE '"activationType"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

          if [ "$ACTION" = "actionClicked" ] || [ "$ACTION" = "contentsClicked" ]; then
            open -b "$APP"
            if [ -n "$TMUX_CLIENT" ] && [ -n "$TMUX_TARGET" ]; then
              tmux -S "$TMUX_SOCKET" switch-client -c "$TMUX_CLIENT" -t "$TMUX_TARGET"
            fi
          fi
        ) &
        disown
      '';
    };
    lspServers = {
      typescript-lsp = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ts = "typescript";
          tsx = "typescriptreact";
          js = "javascript";
          jsx = "javascriptreact";
        };
      };
      gopls = {
        command = "gopls";
        extensionToLanguage = {
          go = "go";
        };
      };
      vscode-json-language-server = {
        command = "vscode-json-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          json = "json";
          jsonc = "jsonc";
        };
      };
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
