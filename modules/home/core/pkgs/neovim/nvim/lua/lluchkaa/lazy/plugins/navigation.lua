if vim.env.REX_BLOCK and not vim.env.TMUX then
  local rex = vim.fn.exepath("rex")
  if rex == "" and vim.fn.has("mac") == 1 then
    rex = "/Applications/Rex.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
  end
  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      local current = vim.api.nvim_get_current_win()
      vim.cmd.wincmd(key)
      if current == vim.api.nvim_get_current_win() then
        vim.system({ rex, "focus", direction }, { text = true }, function(result)
          if result.code ~= 0 then
            vim.schedule(function()
              vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
            end)
          end
        end)
      end
    end, { desc = "Focus split or Rex pane " .. direction })
  end
  return {}
end

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
