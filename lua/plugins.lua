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
    vim.api.nvim_set_keymap(modes, keys, cmd, opts)
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
        end
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
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
            kmap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>")
            kmap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').git_files()<CR>")
            kmap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').git_status()<CR>")
            kmap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<CR>")
            kmap('n', '<leader>ft', "<cmd>lua require('telescope.builtin').tags()<CR>")
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
                    'python', 'rust', 'vim', 'yaml', 'zig',
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
        tag = 'release',
        config = function()
            require('gitsigns').setup({
                signcolumn = true,

                keymaps = {
                    noremap = true,

                    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'" },
                    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'" },

                    ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
                    ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
                },

                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    delay = 5000,
                },
                current_line_blame_formatter_opts = {
                    relative_time = true,
                },
            })

            vim.cmd [[hi! link GitSignsCurrentLineBlame Comment]]
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
                    lualine_x = { 'encoding', 'fileformat', 'filetype', 'lsp_progress' },
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
            'hrsh7th/cmp-path',
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
                    { name = 'buffer', },
                },
            })
        end
    }

    use {
        'simrat39/rust-tools.nvim',
        after = { 'nvim-lspconfig', 'nvim-cmp' },
        config = function()
            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
                local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

                local opts = { noremap = true, silent = true, }

                -- See `:help vim.lsp.*` for documentation on any of the below functions
                buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
                buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
                buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
                buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
                buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
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
