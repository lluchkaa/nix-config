return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      notify = false,
      icons = {
        mappings = vim.g.have_nerd_font,
      },
    },
    keys = {
      { "<leader>c", desc = "[C]ode" },
      { "<leader>d", desc = "[D]ocument" },
      { "<leader>g", desc = "[G]it" },
      { "<leader>r", desc = "[R]ename" },
      { "<leader>s", desc = "[S]earch" },
      { "<leader>w", desc = "[W]orkspace" },
    },
  },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      disable_mouse = false,
      restricted_keys = {
        ["<C-N>"] = {},
        ["<C-P>"] = {},
      },
    },
  },
}
