return {
  {
    "stevearc/oil.nvim",
    enabled = true,
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open oil" },
    },
    opts = {
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
      win_options = {
        signcolumn = "yes",
      },
      view_options = {
        show_hidden = true,
      },
    },
  },
  {
    "A7Lavinraj/fyler.nvim",
    enabled = false,
    branch = "stable",
    lazy = false,
    dependencies = { "echasnovski/mini.icons" },
    keys = {
      { "-", function() require("fyler").open() end, desc = "Open fyler" },
    },
    opts = {
      integrations = {
        icon = "mini_icons",
        winpick = "snacks",
      },
      views = {
        finder = {
          default_explorer = true,
          follow_current_file = true,
          win = {
            win_opts = {
              cursorline = true,
              number = true,
              relativenumber = true,
              signcolumn = "yes",
            },
          },
        },
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup({
        settings = {
          save_on_toggle = true,
        },
      })
    end,
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "[H]arpoon [A]dd file" },
      {
        "<leader>he",
        function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
        desc = "[H]arpoon [E]xplorer",
      },
    },
  },
}
