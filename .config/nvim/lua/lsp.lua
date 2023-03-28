local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
    local kmap = require('utils').kmap
    local opts = { noremap = true, silent = true, buffer = bufnr, }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    kmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    kmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    kmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    kmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    kmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    kmap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    kmap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    kmap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    kmap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    kmap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    kmap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    kmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    kmap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    kmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    kmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    kmap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    kmap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

function M.capabilities()
    return require('cmp_nvim_lsp').default_capabilities()
end

return M
