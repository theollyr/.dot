local fn = vim.fn
local install_path = fn.stdpath('data')
install_path = install_path .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({
        'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path
    })
end

function kmap(modes, keys, cmd, args)
    local opts = args or { silent = true, noremap = true, }

    if vim.version().api_level >= 9 then
        vim.keymap.set(modes, keys, cmd, opts)
    else
        if opts.buffer then
            local bufnr = opts.buffer
            opts['buffer'] = nil

            vim.api.nvim_buf_set_keymap(bufnr, modes, keys, cmd, opts)
        else
            vim.api.nvim_set_keymap(modes, keys, cmd, opts)
        end
    end
end

return require('packer').startup(function()
    -- Packer itself
    use {
        'wbthomason/packer.nvim',
        config = function()
            kmap('n', '<leader>pc', "<cmd>lua require('packer').compile()<CR>")

            -- auto-compile every time the plugins.lua file is changed
            vim.cmd [[
                augroup packer_user_config
                    autocmd!
                    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
                augroup end
            ]]
        end
    }

    -- easy un-/commenting of code
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    -- vim-repeat is important for vim-surround so that it allows the commands
    -- to be dot repeatable
    use {
        'tpope/vim-surround',
        requires = 'tpope/vim-repeat',
    }

    use {
        'ellisonleao/gruvbox.nvim',
        config = function()
            vim.opt.background = 'dark'
            vim.opt.termguicolors = true

            vim.cmd [[colorscheme gruvbox]]

            local diff_colors = {
                DiffAdd = '#34381b',
                DiffDelete = '#402120',
                DiffText = '#3b2d17',
                DiffChange = '#0e363e',
            }

            for hig, bg in pairs(diff_colors) do
                vim.cmd('hi clear ' .. hig)
                vim.cmd(string.format("hi %s guibg=%s", hig, bg))
            end

            -- disable italic on comments but keep it for line blame
            vim.cmd [[
                hi clear GitSignsCurrentLineBlame
                hi GitSignsCurrentLineBlame guifg=#928374 gui=italic

                hi Comment gui=NONE

                hi clear TSComment
                hi! link TSComment Comment
            ]]
        end
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
        -- keys = { { 'n', '<leader>f' }, { 'n', '<leader><leader>' }, },
        config = function()
            local remap_preview_scrolls = {
                -- remove default <C-u> and <C-d> for scrolling
                -- preview, and replace with <C-k> and <C-j>
                ['<C-u>'] = false,
                ['<C-d>'] = false,

                ['<C-k>'] = 'preview_scrolling_up',
                ['<C-j>'] = 'preview_scrolling_down',
            }

            require('telescope').setup({
                defaults = require('telescope.themes').get_ivy({
                    mappings = {
                        i = remap_preview_scrolls,
                        n = remap_preview_scrolls,
                    },
                }),

                extensions = {
                    fzf = {
                        fuzzy = true,
                        case_mode = 'smart_case',
                        override_generic_sorter = true,
                        override_file_sorter = true,
                    },
                },
            })

            -- default TelescopeSelection links to Visual which doesn't look
            -- that good, change it to bg:dark1 from gruvbox
            -- vim.cmd [[
            --     hi! TelescopeSelection guibg=#3c3836
            -- ]]

            kmap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<CR>")
            kmap('n', '<leader>fd', "<cmd>lua require('telescope.builtin').diagnostics()<CR>")
            kmap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>")
            kmap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').git_files()<CR>")
            kmap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').highlights()<CR>")
            kmap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').git_status()<CR>")
            kmap('n', '<leader>ft', "<cmd>lua require('telescope.builtin').tags()<CR>")
            kmap('n', '<leader>f?', "<cmd>lua require('telescope.builtin').help_tags()<CR>")

            -- quicker to press alternatives
            kmap('n', '<leader><leader>', "<cmd>lua require('telescope.builtin').buffers()<CR>")
            kmap('n', '<leader>f<leader>', "<cmd>lua require('telescope.builtin').git_files()<CR>")
        end
    }

    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        after = 'telescope.nvim',
        run = 'make',
        config = function()
            require('telescope').load_extension('fzf')
        end,
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'bash', 'c', 'devicetree', 'fish', 'json', 'lua', 'make',
                    'markdown', 'python', 'rust', 'vim', 'yaml', 'zig',
                },

                highlight = {
                    enable = true,
                },

                indent = {
                    enable = true,
                },
            })
        end
    }

    use {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
        end
    }

    -- indent guides
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('indent_blankline').setup({
                show_current_context = true,
            })

            -- vim.cmd [[hi! link IndentBlanklineContextChar GruvboxOrange]]
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('gitsigns').setup({
                signcolumn = true,

                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    delay = 5000,
                },

                current_line_blame_formatter = function(name, blame_info, opts)
                    if blame_info.author == name then
                        blame_info.author = 'You'
                    end

                    local text
                    if blame_info.author == 'Not Committed Yet' then
                        text = 'You • Uncommitted changes'
                    else
                        local date_time

                        local author_time = tonumber(blame_info['author_time'])
                        if opts.relative_time then
                            date_time = require('gitsigns.util').get_relative_time(author_time)
                        else
                            date_time = os.date('%Y-%m-%d', author_time)
                        end

                        text = string.format('%s, %s • %s', blame_info.author, date_time, blame_info.summary)
                    end

                    return {{' '..text, 'GitSignsCurrentLineBlame'}}
                end,

                current_line_blame_formatter_opts = {
                    relative_time = true,
                },

                on_attach = function(bufnr)
                    local gs = require('gitsigns')

                    local opts = { silent = true, noremap = true, expr = true, buffer = bufnr, }
                    kmap('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", opts)
                    kmap('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", opts)

                    opts = { silent = true, noremap = true, buffer = bufnr, }
                    kmap({ 'n', 'v', }, '<leader>hs', gs.stage_hunk, opts)
                    kmap({ 'n', 'v', }, '<leader>hr', gs.reset_hunk, opts)

                    kmap('n', '<leader>hp', gs.preview_hunk, opts)

                    -- object
                    kmap({ 'o', 'x', }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', opts)
                end,
            })
        end
    }

    use {
        'tpope/vim-fugitive',
        keys = { { 'n', '<leader>d' }, },
        cmd = { 'Git', 'G', },
        config = function()
            kmap('n', '<leader>ds', "<cmd>tab Gvdiffsplit<CR>")
            kmap('n', '<leader>dc', "<cmd>tabclose<CR>")
            kmap('n', '<leader>dg', "<cmd>Git<CR>")
        end
    }

    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'gruvbox',
                    section_separators = '',
                    component_separators = '',
                },
                sections = {
                    lualine_x = { 'lsp_progress', 'encoding', 'fileformat', 'filetype', },
                },
                inactive_sections = {
                    lualine_x = { 'location', },
                },
            })
        end
    }

    use {
        'arkav/lualine-lsp-progress',
        after = 'lualine.nvim',
    }

    use {
        'romgrk/barbar.nvim',
        config = function()
            vim.g.bufferline = {
                auto_hide = false,

                -- don't display the X
                closable = false,

                -- true | 'numbers' | 'both'
                icons = 'numbers',

                -- default is to insert after current buffer
                -- insert_at_start = false,
                insert_at_end = true,

                maximum_length = 30,
            }

            kmap('n', '<leader>bd', "<cmd>BufferClose<CR>")

            -- magical pick
            kmap('n', '<leader>bb', "<cmd>BufferPick<CR>")

            -- moving around and MOVING around
            kmap('n', '<A-,>', "<cmd>BufferPrevious<CR>")
            kmap('n', '<A-.>', "<cmd>BufferNext<CR>")
            kmap('n', '<A-<>', "<cmd>BufferMovePrevious<CR>")
            kmap('n', '<A->>', "<cmd>BufferMoveNext<CR>")

            -- goto's
            kmap('n', '<leader>1', "<cmd>BufferGoto 1<CR>")
            kmap('n', '<leader>2', "<cmd>BufferGoto 2<CR>")
            kmap('n', '<leader>3', "<cmd>BufferGoto 3<CR>")
            kmap('n', '<leader>4', "<cmd>BufferGoto 4<CR>")
            kmap('n', '<leader>5', "<cmd>BufferGoto 5<CR>")
            kmap('n', '<leader>6', "<cmd>BufferGoto 6<CR>")
            kmap('n', '<leader>7', "<cmd>BufferGoto 7<CR>")
            kmap('n', '<leader>8', "<cmd>BufferGoto 8<CR>")
            kmap('n', '<leader>9', "<cmd>BufferGoto 9<CR>")
            kmap('n', '<leader>0', "<cmd>BufferLast<CR>")

            -- :BufferWipeout<CR>
            -- :BufferCloseBuffersLeft<CR>
            -- :BufferCloseBuffersRight<CR>

            -- close others
            kmap('n', '<leader>bo', "<cmd>BufferCloseAllButCurrent<CR>")

            -- sort automatically by...
            kmap('n', '<Space>bsn', "<cmd>BufferOrderByBufferNumber<CR>")
            kmap('n', '<Space>bsd', "<cmd>BufferOrderByDirectory<CR>")
            kmap('n', '<Space>bsl', "<cmd>BufferOrderByLanguage<CR>")
        end
    }

    use {
        'ethanholz/nvim-lastplace',
        config = function()
            require('nvim-lastplace').setup({
                lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help', },
                lastplace_ignore_filetype = { 'gitcommit', 'gitrebase', },
                lastplace_open_folds = true,
            })
        end
    }

    use {
        'neovim/nvim-lspconfig',
        config = function()
            local opts = { silent = true, noremap = true, }

            kmap('n', '<leader>ls', "<cmd>LspStart<CR>")
            kmap('n', '<leader>lr', "<cmd>LspRestart<CR>")
            kmap('n', '<leader>lx', "<cmd>LspStop<CR>")
            kmap('n', '<leader>li', "<cmd>LspInfo<CR>")
        end
    }

    use {
        'onsails/diaglist.nvim',
        after = {
            'nvim-lspconfig',

            -- the one that actually initializes LSP
            -- TODO: initialize LSP on its own
            'rust-tools.nvim',
        },
        config = function()
            require('diaglist').init()

            local opts = { silent = true, noremap = true, }
            kmap('n', '<leader>da', "<cmd>lua require('diaglist').open_all_diagnostics()<CR>")
            kmap('n', '<leader>db', "<cmd>lua require('diaglist').open_buffer_diagnostics()<CR>")
        end
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'quangnguyen30192/cmp-nvim-tags',
        },
        after = 'nvim-lspconfig',
        config = function()
            vim.opt.completeopt = { 'menu', 'menuone', 'noselect', }

            local cmp = require('cmp')
            cmp.setup({
                mapping = {
                    ['<C-k>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c', }),
                    ['<C-j>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c', }),
                    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c', }),
                },
                sources = {
                    { name = 'nvim_lsp', },
                    { name = 'tags', },
                    {
                        name = 'buffer',
                        option = {
                            -- gather completion from all open buffers
                            get_bufnrs = function() return vim.api.nvim_list_bufs() end,
                        },
                    },
                },
            })
        end
    }

    use {
        'simrat39/rust-tools.nvim',
        after = { 'nvim-lspconfig', 'nvim-cmp' },
        ft = { 'rust', 'toml', },
        config = function()
            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
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

            local capabilities = vim.lsp.protocol.make_client_capabilities();
            capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

            require('rust-tools').setup({
                -- all the opts to send to nvim-lspconfig
                server = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                    flags = {
                        debounce_text_changes = 150,
                    },
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                            },
                            checkOnSave = {
                                allFeatures = true,
                            },
                        },
                    },
                },
            })

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics, {
                    underline = false,
                    virtual_text = true,
                    signs = true,
                    update_in_insert = false,
                }
            )
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
