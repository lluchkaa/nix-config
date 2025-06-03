return {
  {
    "stevearc/oil.nvim",
    dependencies = { "echasnovski/mini.icons" },
    config = function()
      require("oil").setup({
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

      vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = "navigate to file 1" })
      vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = "navigate to file 2" })
      vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = "navigate to file 3" })
    end,
  },
}
