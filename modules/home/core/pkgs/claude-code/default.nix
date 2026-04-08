{ pkgs, config, claude-plugins, ... }:
{
  home.packages = [
    pkgs.typescript-language-server
    pkgs.gopls
    pkgs.vscode-langservers-extracted
    pkgs.lua-language-server
    pkgs.rustup
  ];

  programs.claude-code = {
    enable = true;
    plugins = map (name: "${claude-plugins}/plugins/${name}") [
      "clangd-lsp"
      "gopls-lsp"
      "lua-lsp"
      "pyright-lsp"
      "rust-analyzer-lsp"
      "typescript-lsp"
    ];
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
          if [ -z "$TMUX_CLIENT" ]; then
            TMUX_CLIENT=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_PANE" -p '#{client_name}' 2>/dev/null)
          fi

          # Check if Claude is in a sidekick session: look for an external tmux-attach
          # client (e.g. from Neovim :terminal), find the pane it lives in, and switch there.
          SESSION_NAME=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_PANE" -p '#{session_name}' 2>/dev/null)
          PANE_MAP=$(tmux -S "$TMUX_SOCKET" list-panes -a -F '#{pane_pid}|#{session_name}:#{window_index}.#{pane_index}|#{pane_id}' 2>/dev/null)

          while IFS='|' read -r ext_client ext_pid; do
            PID=$ext_pid
            i=0
            while [ $i -lt 20 ]; do
              i=$((i + 1))
              MATCH=$(echo "$PANE_MAP" | grep "^$PID|")
              if [ -n "$MATCH" ]; then
                NVIM_TARGET=$(echo "$MATCH" | cut -d'|' -f2)
                NVIM_PANE_ID=$(echo "$MATCH" | cut -d'|' -f3)
                NVIM_CLIENT=$(tmux -S "$TMUX_SOCKET" list-clients -F '#{client_name}' -t "$NVIM_TARGET" 2>/dev/null | head -1)
                if [ -n "$NVIM_CLIENT" ] && [ -n "$NVIM_TARGET" ]; then
                  TMUX_CLIENT="$NVIM_CLIENT"
                  TMUX_TARGET="$NVIM_TARGET"
                fi
                break
              fi
              PID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
              if [ -z "$PID" ] || [ "$PID" -le 1 ]; then break; fi
            done
          done < <(tmux -S "$TMUX_SOCKET" list-clients -t "$SESSION_NAME" -F '#{client_name}|#{client_pid}' 2>/dev/null | grep -v "^$TMUX_CLIENT|")
        fi

        ICON="${config.xdg.dataHome}/icons/claude.png"

        (
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
        ) </dev/null >/dev/null 2>&1 &
        disown
      '';
    };
    lspServers = {
      typescript-lsp = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };
      gopls = {
        command = "gopls";
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      vscode-json-language-server = {
        command = "vscode-json-language-server";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".json" = "json";
          ".jsonc" = "jsonc";
        };
      };
      lua-language-server = {
        command = "lua-language-server";
        extensionToLanguage = {
          ".lua" = "lua";
        };
      };
      rust-analyzer = {
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
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
