return {
  "folke/zen-mode.nvim",
  enabled = false,
  config = function()
    local zen = require("zen-mode")

    zen.setup({
      window = {
        backdrop = 0,
      },
      plugins = {
        gitsigns = { enabled = false },
        tmux = { enabled = false },
        wezterm = {
          enabled = true,
          font = "+4",
        },
      },
    })

    vim.api.nvim_set_hl(0, "ZenBg", { ctermbg = 0 })
  end,
}
