local prefix = "ctrl+a>"

-- Pane navigation and resize.
rex.mode("repeat", { exclusive = true })
rex.bind(prefix .. "r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  local chord = "ctrl+" .. key
  local action = "navigate_" .. direction
  rex.action({
    name = action,
    title = "Navigate " .. direction,
    run = function()
      local ok, process = pcall(rex.block.call, "com.superlogical.terminal", "process", {})
      local name = ok and process.foreground and process.foreground.name or ""
      if name:find("nvim", 1, true) or name:match("^tmux") then
        rex.client.queue("pane.send_key", { key = chord })
      else
        rex.client.queue("pane.focus", { direction = direction })
      end
    end,
  })
  rex.bind(chord, action)
  rex.bind(prefix .. key, "pane.focus", { direction = direction })
  rex.bind(prefix .. "shift+" .. key, "pane.resize", { amount = 10, direction = direction })
  rex.bind("repeat/shift+" .. key, "pane.resize", { amount = 10, direction = direction })
end

rex.bind(prefix .. "shift+5", "pane.split.right") -- %
rex.bind(prefix .. "shift+[Quote]", "pane.split.down") -- "
rex.bind(prefix .. "o", "pane.focus_next")
rex.bind(prefix .. ";", "pane.focus_recent.in_tab")
rex.bind(prefix .. "z", "pane.zoom")
rex.bind(prefix .. "shift+1", "pane.move_to_new_tab") -- !
rex.bind(prefix .. "x", "client.close")

-- Tabs and sessions.
rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")
rex.bind(prefix .. "tab", "client.tab.recent.in_session")
rex.bind(prefix .. ",", "client.tab.rename")
rex.bind(prefix .. "shift+7", "client.tab.close") -- &
rex.bind(prefix .. "w", "pane.go_to")

for index = 1, 9 do
  rex.bind(prefix .. index, "client.tab.goto", { index = index })
end

rex.bind(prefix .. "ctrl+c", "session.new")
rex.bind(prefix .. "s", "session.switch")
rex.bind(prefix .. "shift+9", "session.previous") -- (
rex.bind(prefix .. "shift+0", "session.next") -- )
rex.bind(prefix .. "shift+4", "session.rename") -- $

-- Rex copy mode already uses v to select and y to yank.
rex.bind(prefix .. "[", "pane.copy_mode.enter")
rex.bind(prefix .. "]", "pane.paste")
rex.bind(prefix .. "shift+;", "client.palette.toggle") -- :
rex.bind(prefix .. "shift+r", "client.config.reload")
rex.bind(prefix .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })
