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
      *Code*)       echo "com.microsoft.VSCode|$PID";   return ;;
      *wezterm*)    echo "com.github.wez.wezterm|$PID"; return ;;
      *iTerm*)      echo "com.googlecode.iterm2|$PID";  return ;;
      *Warp*)       echo "dev.warp.Warp-Stable|$PID";   return ;;
      *Alacritty*)  echo "io.alacritty|$PID";           return ;;
      *kitty*)      echo "net.kovidgoyal.kitty|$PID";   return ;;
      *ghostty*)    echo "com.mitchellh.ghostty|$PID";  return ;;
    esac
  done
}

APP="com.apple.Terminal"
APP_PID=""
TMUX_SOCKET=""
TMUX_CLIENT=""
TMUX_TARGET=""

if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
  TMUX_SOCKET="${TMUX%%,*}"
fi

if [ -n "$TMUX_SOCKET" ]; then
  while IFS='|' read -r client_name client_pid; do
    FOUND=$(find_app "$client_pid")
    if [ -n "$FOUND" ]; then
      APP="${FOUND%%|*}"
      APP_PID="${FOUND##*|}"
      TMUX_CLIENT="$client_name"
      break
    fi
  done < <(tmux -S "$TMUX_SOCKET" list-clients -F '#{client_name}|#{client_pid}' 2>/dev/null)
else
  FOUND=$(find_app $$)
  if [ -n "$FOUND" ]; then
    APP="${FOUND%%|*}"
    APP_PID="${FOUND##*|}"
  else
    case "$TERM_PROGRAM" in
      ghostty)    APP="com.mitchellh.ghostty" ;;
      vscode)     APP="com.microsoft.VSCode" ;;
      WezTerm)    APP="com.github.wez.wezterm" ;;
      iTerm.app)  APP="com.googlecode.iterm2" ;;
    esac
  fi
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

ICON="@iconsDir@/claude-code.png"

is_active() {
  local frontmost
  frontmost=$(osascript -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true' 2>/dev/null)
  [ "$frontmost" != "$APP" ] && return 1

  if [ -n "$TMUX_SOCKET" ]; then
    local pane_active client_view target_view
    pane_active=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_TARGET" -p '#{pane_active}' 2>/dev/null)
    [ "$pane_active" != "1" ] && return 1
    client_view=$(tmux -S "$TMUX_SOCKET" display-message -t "$TMUX_CLIENT" -p '#{session_name}:#{window_index}' 2>/dev/null)
    target_view="${TMUX_TARGET%.*}"
    [ "$client_view" = "$target_view" ] && return 0
    return 1
  fi

  if [ "$APP" = "com.microsoft.VSCode" ] && [ -n "$PWD" ]; then
    local ws focused_window
    ws=$(basename "$PWD")
    focused_window=$(osascript -e 'tell application "System Events" to tell process "Code" to get name of first window' 2>/dev/null)
    echo "$focused_window" | grep -qF "$ws" && return 0
    return 1
  fi

  return 0
}

focus_app() {
  if [ "$APP" = "com.microsoft.VSCode" ] && [ -n "$PWD" ]; then
    local ws
    ws=$(basename "$PWD")
    osascript 2>/dev/null << EOF || open -b "$APP"
tell application "System Events"
  tell process "Code"
    set targetWindows to (every window whose name contains "$ws")
    if (count of targetWindows) > 0 then
      perform action "AXRaise" of item 1 of targetWindows
    end if
  end tell
end tell
tell application "Visual Studio Code" to activate
EOF
  elif [ -n "$APP_PID" ]; then
    osascript 2>/dev/null << EOF || open -b "$APP"
tell application "System Events"
  set proc to first process whose unix id is $APP_PID
  if (count of windows of proc) > 0 then
    perform action "AXRaise" of first window of proc
  end if
  set frontmost of proc to true
end tell
EOF
  elif [ -n "$APP" ]; then
    open -b "$APP"
  fi
}

(
  (
    is_active && exit 0
    RESULT=$(alerter --title "$TITLE" --message "$MESSAGE" --app-icon "$ICON" --actions "Open" --timeout 60 --json --ignore-dnd)
    ACTION=$(echo "$RESULT" | grep -oE '"activationType"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

    if [ "$ACTION" = "actionClicked" ] || [ "$ACTION" = "contentsClicked" ]; then
      focus_app
      if [ -n "$TMUX_CLIENT" ] && [ -n "$TMUX_TARGET" ]; then
        tmux -S "$TMUX_SOCKET" switch-client -c "$TMUX_CLIENT" -t "$TMUX_TARGET"
      fi
    fi
  ) &
) </dev/null >/dev/null 2>&1 &
disown
