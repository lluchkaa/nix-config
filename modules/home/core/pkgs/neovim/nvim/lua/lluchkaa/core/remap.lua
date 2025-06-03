vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set({ "n", "v", "x" }, "<Left>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Right>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Up>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Down>", "<nop>")

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "next match" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "previous match" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "paste over selection" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "copy to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "copy to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete to blackhole" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "escape" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
