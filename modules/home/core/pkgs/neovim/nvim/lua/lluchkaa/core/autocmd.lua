vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restore cursor to last known position",
  group = vim.api.nvim_create_augroup("restore-cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Equalize splits on terminal resize",
  group = vim.api.nvim_create_augroup("equalize-splits", { clear = true }),
  callback = function() vim.cmd("wincmd =") end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  desc = "Disable spell in non-prose filetypes",
  group = vim.api.nvim_create_augroup("spell-exceptions", { clear = true }),
  callback = function()
    local ft = vim.bo.filetype
    local no_spell = { "terminal", "help", "man", "checkhealth", "qf", "TelescopePrompt", "trouble" }
    if vim.tbl_contains(no_spell, ft) then
      vim.opt_local.spell = false
    end
  end,
})
