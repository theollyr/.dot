vim.g.mapleader = " "
vim.g.localmapleader = " "

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- <leader>p to paste, but/and preserve yank buffer
vim.keymap.set("v", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y") -- do I need this?
vim.keymap.set("v", "<leader>y", "\"+y")

-- move text around in visual mode, re-aligning it
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- make % executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
