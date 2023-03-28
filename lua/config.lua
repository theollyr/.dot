vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true

vim.opt.mouse = 'a'

-- display line numbers (relative)
vim.opt.number = true
vim.opt.relativenumber = true

-- highlight current line
vim.opt.cursorline = true

vim.opt.scrolloff = 5

vim.opt.colorcolumn = { 79, 99 }

vim.opt.cmdheight = 2

vim.opt.signcolumn = 'yes'

vim.opt.list = true
vim.opt.listchars:append('trail:•')

vim.opt.guifont = {
    'FiraCode Nerd Font:h11',
    'SauceCodePro Nerd Font:h11',
}

vim.cmd [[
augroup YankHighlight
    au!
    au TextYankPost * silent! lua require('highlight').on_yank()
augroup END
]]

-- When pressing <C-6>, Neovide actually sends <C-6> and not <C-^> which is
-- what happens in a terminal. Map it to <C-^> so the behaviour is consistent.
require('utils').kmap('n', '<C-6>', '<C-^>', { silent = true, })

require('utils').kmap('n', '<leader>o', '<C-^>', { silent = true, })
