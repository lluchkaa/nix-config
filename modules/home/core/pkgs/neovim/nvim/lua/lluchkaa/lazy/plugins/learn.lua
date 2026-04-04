return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      notify = false,
      icons = {
        mappings = vim.g.have_nerd_font,
      },
      spec = {
        { "<leader>a", group = "[A]I" },
      { "<leader>h", group = "[H]arpoon" },
        { "<leader>c", group = "[C]ode" },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>g", group = "[G]it" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>x", group = "[X] Diagnostics" },
      },
    },
  },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
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
