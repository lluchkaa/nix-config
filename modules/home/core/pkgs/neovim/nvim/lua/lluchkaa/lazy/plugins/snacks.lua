return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      image = { enabled = true },
      lazygit = { enabled = true },
      zen = { enabled = true },
      gitbrowse = { enabled = true },
    },
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "[G]it lazygit" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "[G]it [B]rowse" },
    },
  },
}
