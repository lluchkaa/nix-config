return {
  {
    "stevearc/oil.nvim",
    dependencies = { "echasnovski/mini.icons" },
    config = function()
      local oil = require("oil")
      oil.setup({
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
      })

      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open oil" })
    end,
  },
  {
    "A7Lavinraj/fyler.nvim",
    enabled = false,
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable", -- Use stable branch for production
    opts = {
      views = {
        finder = {
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
    config = function(_, opts)
      local fyler = require("fyler")
      fyler.setup(opts)
      vim.keymap.set("n", "<leader>e", fyler.open, { desc = "Open fyler View" })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
        },
      })

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "add file to harpoon" })
      vim.keymap.set(
        "n",
        "<leader>he",
        function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "toggle harpoon UI" }
      )

      -- Disabled this because of vim-tmux-navigator
      -- vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = "navigate to file 1" })
      -- vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = "navigate to file 2" })
      -- vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = "navigate to file 3" })
    end,
  },
}
