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

kmap = require('utils').kmap

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
                hi GitSignsCurrentLineBlame guifg=#928374 cterm=italic gui=italic

                hi Comment cterm=NONE gui=NONE

                hi clear TSComment
                hi! link TSComment Comment

                " ellisonleao/gruvbox.nvim#e57dd85 made it italic
                hi String cterm=NONE gui=NONE
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

                    local date_time

                    local author_time = tonumber(blame_info['author_time'])
                    if opts.relative_time then
                        date_time = require('gitsigns.util').get_relative_time(author_time)
                    else
                        date_time = os.date('%Y-%m-%d', author_time)
                    end

                    text = string.format('%s, %s • %s', blame_info.author, date_time, blame_info.summary)
                    return {{' '..text, 'GitSignsCurrentLineBlame'}}
                end,

                current_line_blame_formatter_nc = function(name, blame_info, opts)
                    return {{' Unknown • Uncommitted changes ', 'GitSignsCurrentLineBlame'}}
                end,

                on_attach = function(bufnr)
                    local gs = require('gitsigns')

                    local opts = { silent = true, noremap = true, expr = true, buffer = bufnr, }
                    kmap('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", opts)
                    kmap('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", opts)

                    opts = { silent = true, noremap = true, buffer = bufnr, }
                    kmap({ 'n', 'v', }, '<leader>hs', gs.stage_hunk, opts)
                    kmap({ 'n', 'v', }, '<leader>hr', gs.reset_hunk, opts)

                    kmap('n', '<leader>hp', gs.preview_hunk, opts)
                    kmap('n', '<leader>hb', gs.blame_line, opts)

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
            local filename = {
                'filename',
                path = 1,
                symbols = {
                    readonly = '[RO]',
                },
            }

            require('lualine').setup({
                options = {
                    theme = 'gruvbox',
                    section_separators = '',
                    component_separators = '',
                },
                sections = {
                    lualine_c = { filename, },
                    lualine_x = { 'lsp_progress', 'encoding', 'fileformat', 'filetype', },
                },
                inactive_sections = {
                    lualine_c = { filename, },
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
        ft = { 'zig', 'rust', },
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
        config = function()
            vim.opt.completeopt = { 'menu', 'menuone', 'noselect', }

            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-j>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-f>'] = cmp.mapping.confirm({ select = true, }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp', },
                    { name = 'tags', },
                }, {
                    {
                        name = 'buffer',
                        option = {
                            -- gather completion from all open buffers
                            get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
                        },
                    },
                }),
            })
        end
    }

    use {
        'simrat39/rust-tools.nvim',
        opt = true,
        after = { 'nvim-lspconfig', 'nvim-cmp' },
        ft = { 'rust', 'toml', },
        config = function()
            local lsp = require('lsp')

            require('rust-tools').setup({
                -- all the opts to send to nvim-lspconfig
                server = {
                    on_attach = lsp.on_attach,
                    capabilities = lsp.capabilities(),
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
                vim.lsp.diagnostic.on_publish_diagnostics,
                {
                    underline = false,
                    virtual_text = true,
                    signs = true,
                    update_in_insert = false,
                }
            )
        end
    }

    use {
        'ziglang/zig.vim',
        opt = true,
        ft = { 'zig', },
        config = function()
            local lsp = require('lsp')
            require('lspconfig').zls.setup({
                on_attach = lsp.on_attach,
                capabilities = lsp.capabilities(),
            })
        end
    }

    use {
        'vlime/vlime',
        opt = true,
        ft = { 'lisp', },
        config = function()
            vim.g.vlime_cl_impl = 'ccl'
        end
    }

    use {
        'junegunn/vim-easy-align',
        config = function()
            kmap('n', 'ga', '<Plug>(EasyAlign)', {})
            kmap('x', 'ga', '<Plug>(EasyAlign)', {})

            kmap('n', 'gi', '<Plug>(LiveEasyAlign)', {})
            kmap('x', 'gi', '<Plug>(LiveEasyAlign)', {})

            vim.g.easy_align_delimiters = {
                ['\\'] = { pattern = '\\\\' },
            }
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
