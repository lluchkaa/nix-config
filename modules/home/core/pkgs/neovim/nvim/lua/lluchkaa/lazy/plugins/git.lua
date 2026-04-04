return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    dependencies = { "tpope/vim-rhubarb" },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "┃" },
        change       = { text = "┃" },
        delete       = { text = "▼" },
        topdelete    = { text = "▲" },
        changedelete = { text = "┃" },
      },
      signs_staged = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▾" },
        topdelete    = { text = "▴" },
        changedelete = { text = "▎" },
      },
      signs_staged_enable = true,
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Hunk navigation (smart: works in diff mode too)
        vim.keymap.set("n", "]h", function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
          else gs.nav_hunk("next") end
        end, { buffer = bufnr, desc = "Git: Next [H]unk" })

        vim.keymap.set("n", "[h", function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
          else gs.nav_hunk("prev") end
        end, { buffer = bufnr, desc = "Git: Prev [H]unk" })

        map("<leader>gs", gs.stage_hunk, "[S]tage hunk")
        map("<leader>gr", gs.reset_hunk, "[R]eset hunk")
        map("<leader>gS", gs.stage_buffer, "[S]tage buffer")
        map("<leader>gp", gs.preview_hunk, "[P]review hunk")
        map("<leader>gb", gs.toggle_current_line_blame, "Toggle line [B]lame")
        map("<leader>gd", gs.diffthis, "[D]iff this")
      end,
    },
  },
}
