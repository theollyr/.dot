-- need to have <leader> setup before lazy.nvim gets loaded up
require("theollyr.kmap")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "folke/lazy.nvim",

    { "nvim-telescope/telescope.nvim", branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local remap_preview_scrolls = {
                -- remove the default <C-u>/<C-d> for preview scrolling
                -- use <C-k>/<C-j> instead
                ["<C-u>"] = false,
                ["<C-d>"] = false,

                ["<C-k>"] = "preview_scrolling_up",
                ["<C-j>"] = "preview_scrolling_down",
            }

            -- setup theme Ivy and update the preview keymaps
            local telescope = require("telescope")
            local themes = require("telescope.themes")
            telescope.setup({
                defaults = themes.get_ivy({
                    mappings = {
                        i = remap_preview_scrolls,
                        n = remap_preview_scrolls,
                    },
                }),
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader><leader>", builtin.buffers)
            vim.keymap.set("n", "<C-p>", builtin.buffers)

            vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
            vim.keymap.set("n", "<leader>ff", builtin.find_files)
            vim.keymap.set("n", "<leader>fg", builtin.git_files)
            vim.keymap.set("n", "<leader>fh", builtin.highlights)
            vim.keymap.set("n", "<leader>fs", builtin.git_status)
            vim.keymap.set("n", "<leader>ft", builtin.tags)
            vim.keymap.set("n", "<leader>f?", builtin.help_tags)
        end,
    },
    { "ellisonleao/gruvbox.nvim", priority = 1000,
        config = function()
            vim.opt.background = "dark"
            vim.opt.termguicolors = true

            require("gruvbox").setup({
                overrides = {
                    DiffAdd = { bg = "#34381b" },
                    DiffDelete = { bg = "#402120" },
                    DiffTest = { bg = "#3b2d17" },
                    DiffChange = { bg = "#0e363e" },
                    Comment = { italic = false },
                    String = { italic = false },
                },
            })
            vim.cmd [[colorscheme gruvbox]]

            vim.cmd [[
                augroup YankHighlight
                    au!
                    au TextYankPost * silent! lua require("theollyr.util").on_yank()
                augroup END
            ]]
        end,
    },
    { "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.install").update({ with_sync = true })
            require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all" (the five listed parsers should always be installed)
                ensure_installed = {
                    "query", "vim", "vimdoc",
                    "bash", "fish", "make",
                    "c", "go", "commonlisp", "lua", "rust", "zig",
                },
                -- List of parsers to ignore installing (for "all")
                -- ignore_install = { "javascript" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = false,

                highlight = {
                    enable = true,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
            })
        end,
    },
    { "tpope/vim-fugitive",
        cmd = "Git",
        keys = { "<leader>gs", "<leader>ds" },
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
            vim.keymap.set("n", "<leader>ds", ":tab Gvdiffsplit<CR>")
            vim.keymap.set("n", "<leader>dc", ":tabclose<CR>")
        end,
    },
    { "VonHeikemen/lsp-zero.nvim", branch = "v2.x",
        ft = { "lua", "rust" },
        dependencies = {
            {"neovim/nvim-lspconfig"},
            { "williamboman/mason.nvim",
                build = ":MasonUpdate",
            },
            {"williamboman/mason-lspconfig.nvim"},

            -- Autocompletion
            {"hrsh7th/nvim-cmp"},
            {"hrsh7th/cmp-nvim-lsp"},
            {"L3MON4D3/LuaSnip"},
        },
        config = function()
            vim.opt.completeopt = { "menu", "menuone", "noselect" }

            local lsp_zero = require("lsp-zero")
            local lsp = lsp_zero.preset("recommended")

            lsp.on_attach(function(_client, bufnr)
                lsp.default_keymaps({ buffer = bufnr })
            end)

            require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
            lsp.setup()

            local cmp = require("cmp")
            local cmp_action = lsp_zero.cmp_action()

            cmp.setup({
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),

                    ["<C-f>"] = cmp_action.luasnip_jump_forward(),
                    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "tags" },
                    {
                        name = "buffer",
                        option = {
                            -- gather completion from all open buffers
                            get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
                        }
                    },
                }
            })
        end,
    },
    { "simrat39/rust-tools.nvim",
        dependencies = {
            -- Debugging
            { "nvim-lua/plenary.nvim" },
            { "mfussenegger/nvim-dap" },
        },
        ft = { "rust" },
        config = function()
            local rt = require("rust-tools")

            rt.setup({
                server = {
                    on_attach = function(_, bufnr)
                        vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
                        vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
                    end,
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
        end,
    },
    { "tpope/vim-surround",
        dependencies = {
            -- to have surround dot-repeatable
            "tpope/vim-repeat",
        },
    },
    { "numToStr/Comment.nvim",
        -- setting to true triggers the default implementation which calls:
        --   require("Comment").setup({})
        config = true,
    },
    { "windwp/nvim-autopairs",
        config = function()
            local ap = require("nvim-autopairs")
            ap.setup({
                check_ts = true,
                disable_filetype = { "TelescopePrompts", "vim" },
            })

            local ap_cmp = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", ap_cmp.on_confirm_done())
        end,
    },
    { "lukas-reineke/indent-blankline.nvim",
        -- passed to `require("indent-blankline").setup(opts)`
        opts = {
            show_current_context = true,
            -- underlines the first line of current context
            show_current_context_start = true,
        },
    },
    { "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signcolumn = true,
            max_file_length = 100000,

            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                delay = 5000,
                ignore_whitespace = true,
            },

            current_line_blame_formatter = function(name, blame_info, opts)
                if blame_info.author == name then
                    blame_info.author = "You"
                end

                local date_time

                local author_time = tonumber(blame_info["author_time"])
                if opts.relative_time then
                    date_time = require("gitsigns.util").get_relative_time(author_time)
                else
                    date_time = os.date("%Y-%m-%d", author_time)
                end

                local text = string.format(
                "%s, %s • %s", blame_info.author, date_time, blame_info.summary)
                return {{" "..text, "GitSignsCurrentLineBlame"}}
            end,

            current_line_blame_formatter_nc = function(_name, _blame_info, _opts)
                return {{" Unknown • Uncommitted changes ", "GitSignsCurrentLineBlame"}}
            end,

            on_attach = function(bufnr)
                local gs = require("gitsigns")

                local opts = { silent = true, noremap = true, expr = true, buffer = bufnr, }
                vim.keymap.set("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() require("gitsigns").next_hunk() end)
                    return "<Ignore>"
                end, opts)
                vim.keymap.set("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() require("gitsigns").prev_hunk() end)
                    return "<Ignore>"
                end, opts)

                opts = { silent = true, noremap = true, buffer = bufnr, }
                vim.keymap.set({ "n", "v", }, "<leader>hs", gs.stage_hunk, opts)
                vim.keymap.set({ "n", "v", }, "<leader>hr", gs.reset_hunk, opts)

                vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
                vim.keymap.set("n", "<leader>hb", gs.blame_line, opts)

                -- object
                vim.keymap.set({ "o", "x", }, "ih", ":<C-U>Gitsigns select_hunk<CR>", opts)
            end,
        },
    },
    { "nvim-lualine/lualine.nvim",
        dependencies = {
            { "arkav/lualine-lsp-progress" },
        },
        config = function()
            local fname = {
                "filename",
                path = 1,
                symbols = {
                    readonly = "[RO]",
                },
            }

            require("lualine").setup({
                options = {
                    theme = "gruvbox",
                    section_separators = "",
                    component_separatcrs = "",
                },
                sections = {
                    lualine_c = { fname },
                    lualine_x = { "lsp_progress", "encoding", "fileformat", "filetype" },
                },
                inactive_sections = {
                    lualine_c = { fname },
                    lualine_x = { "location" },
                },
            })
        end,
    },
    { "ethanholz/nvim-lastplace",
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help", },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", },
            lastplace_open_folds = true,
        },
    },
    { "romgrk/barbar.nvim",
        init = function() vim.g.barbar_auto_setup = false end,
        config = function()
            require("barbar").setup({
                auto_hide = false,

                icons = {
                    buffer_index = true,

                    -- don't show the close (X) button
                    button = false,
                    -- don't show a redundant dot (•) on modified buffers, they
                    -- already show in a different colour
                    modified = { button = false },

                    -- disable filetype icons (requires "nvim-web-devicons")
                    filetype = { enabled = false },
                },

                -- default is to insert after current buffer
                -- insert_at_start = false,
                insert_at_end = true,

                maximum_length = 30,
            })

            vim.keymap.set("n", "<leader>bd", "<cmd>BufferClose<CR>")

            -- magical pick
            vim.keymap.set("n", "<leader>bb", "<cmd>BufferPick<CR>")

            -- moving around and MOVING around
            vim.keymap.set("n", "<A-,>", "<cmd>BufferPrevious<CR>")
            vim.keymap.set("n", "<A-.>", "<cmd>BufferNext<CR>")
            vim.keymap.set("n", "<A-<>", "<cmd>BufferMovePrevious<CR>")
            vim.keymap.set("n", "<A->>", "<cmd>BufferMoveNext<CR>")

            -- goto's
            vim.keymap.set("n", "<leader>1", "<cmd>BufferGoto 1<CR>")
            vim.keymap.set("n", "<leader>2", "<cmd>BufferGoto 2<CR>")
            vim.keymap.set("n", "<leader>3", "<cmd>BufferGoto 3<CR>")
            vim.keymap.set("n", "<leader>4", "<cmd>BufferGoto 4<CR>")
            vim.keymap.set("n", "<leader>5", "<cmd>BufferGoto 5<CR>")
            vim.keymap.set("n", "<leader>6", "<cmd>BufferGoto 6<CR>")
            vim.keymap.set("n", "<leader>7", "<cmd>BufferGoto 7<CR>")
            vim.keymap.set("n", "<leader>8", "<cmd>BufferGoto 8<CR>")
            vim.keymap.set("n", "<leader>9", "<cmd>BufferGoto 9<CR>")
            vim.keymap.set("n", "<leader>0", "<cmd>BufferLast<CR>")

            -- :BufferWipeout<CR>
            -- :BufferCloseBuffersLeft<CR>
            -- :BufferCloseBuffersRight<CR>

            -- close others
            vim.keymap.set("n", "<leader>bo", "<cmd>BufferCloseAllButCurrent<CR>")

            -- sort automatically by...
            vim.keymap.set("n", "<leader>bsn", "<cmd>BufferOrderByBufferNumber<CR>")
            vim.keymap.set("n", "<leader>bsd", "<cmd>BufferOrderByDirectory<CR>")
            vim.keymap.set("n", "<leader>bsl", "<cmd>BufferOrderByLanguage<CR>")

            vim.keymap.set("n", "<leader>o", "<C-^>", { silent = true })
        end,
    },
    { "junegunn/vim-easy-align",
        keys = { "ga", "gi" },
        config = function()
            vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
            vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")

            vim.keymap.set("n", "gi", "<Plug>(LiveEasyAlign)")
            vim.keymap.set("x", "gi", "<Plug>(LiveEasyAlign)")

            vim.g.easy_align_delimiters = {
                ['\\'] = { pattern = '\\\\' },
            }
        end,
    },
})
