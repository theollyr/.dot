vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true

vim.opt.mouse = "a"

-- display relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- highlight current line
vim.opt.cursorline = true

vim.opt.cmdheight = 2
vim.opt.scrolloff = 5

vim.opt.colorcolumn = { 80, 100 }
vim.opt.signcolumn = "yes"

vim.opt.list = true
vim.opt.listchars:append("trail:•")

vim.opt.guifont = {
    'FiraCode Nerd Font:h11',
    'SauceCodePro Nerd Font:h11',
}
