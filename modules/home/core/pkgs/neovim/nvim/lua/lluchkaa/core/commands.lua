vim.api.nvim_create_user_command("CopyPath", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, {})

vim.keymap.set("n", "<leader>cp", "<cmd>CopyPath<CR>", { desc = "[C]opy file [p]ath to clipboard" })
