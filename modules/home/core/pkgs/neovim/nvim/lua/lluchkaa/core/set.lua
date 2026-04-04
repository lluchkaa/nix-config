local c = require("lluchkaa.core.constants")

vim.opt.guicursor = ""

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.mouse = "a"

vim.opt.showmode = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = c.tab_width
vim.opt.softtabstop = c.tab_width
vim.opt.shiftwidth = c.tab_width
vim.opt.expandtab = true

vim.opt.cmdheight = 1
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.inccommand = "split"

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80,120"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.scrolloff = 10
vim.opt.smoothscroll = true

vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"

vim.opt.list = true
vim.opt.listchars = {
  tab = "  ",
  trail = "·",
  eol = "↲",
}

vim.opt.spell = true
vim.opt.spelllang = "en_us"

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
