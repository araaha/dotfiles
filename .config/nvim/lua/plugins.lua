return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = true,
        event = "VeryLazy",
        priority = 1000,
        opts = {
            undercurl = false,
            underline = false,
            bold = false,
            italic = {
                strings = false,
                comments = true,
                operators = false,
                folds = false,
            },
            strikethrough = false,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = false,   -- invert background for search, diffs, statuslines and errors
            contrast = "hard", -- can be "hard", "soft" or empty string
            palette_overrides = {
                bright_green = "#9dc365",
                neutral_green = "#9dc365",
                dark2 = "#7c6f64"
            },
            overrides = {
                Search = { bg = '#7DAEA3', fg = "#242424" },
                IncSearch = { bg = '#D8A657', fg = "#242424" },
                Visual = { bg = '#3f3f3f', fg = 'None' },
                ["@namespace"] = { fg = '#fb4934' },
                ["@variable"] = { fg = '#7DAEA3' },
                Pmenu = { fg = "None", bg = "None" },
                PmenuSel = { fg = "#e6dbaf", bg = "#7DAEA3" },
                PmenuSbar = { fg = "None", bg = "None" },
                PmenuThumb = { fg = "None", bg = "None" },
                ["@constant.bash"] = { fg = "#7DAEA3" },
                ["@function.builtin.bash"] = { fg = "#fb4934" },
                StatusLine = { bg = "#242424", fg = "None" },
                StatusLineNC = { bg = "#242424", fg = "#e6dbaf" },
                QuickFixLine = { bg = "#242424", fg = "None" },
                FloatBorder = { fg = "#87afaf" },
                FzfLuaBufLineNr = { fg = "#87afaf" },
                SpecialKey = { fg = "#7c6f64" },
                NonText = { fg = "#7c6f64" },
                SpecialChar = { fg = "#fb4934" },
                CursorLine = { bg = "#282828" },

            },
            dim_inactive = false,
            transparent_mode = true,
        },
        config = function(_, opts)
            require("gruvbox").setup(opts)
            vim.cmd.colorscheme('gruvbox')
        end
    },
    {
        'ibhagwan/fzf-lua',
        version = false,
        lazy    = true,
        cmd     = "FzfLua",
        keys    = { "<C-t>", " fl" },
        -- event   = "VeryLazy",
        config  = function()
            local fzf = require("fzf-lua")
            local actions = require("fzf-lua").actions
            fzf.setup({
                fzf_bin    = "fzf",
                keymap     = {
                    fzf = {
                        ["ctrl-u"] = "half-page-up"
                    },
                },
                fzf_opts   = {
                    ['--border']         = 'none',
                    ['--padding']        = '0%',
                    ['--margin']         = '0%',
                    ['--no-separator']   = '',
                    ['--preview-window'] = 'up,50%',
                    ['--info']           = 'default',
                },
                fzf_colors = {
                    ['gutter'] = '-1',
                    ['bg'] = '-1',
                },
                blines     = {
                    rg_opts = "--line-number --colors=line:none",
                },
                winopts    = {
                    -- split = "belowright new",
                    preview = {
                        default = "bat",
                        scrollbar = false,
                        delay = 250,
                    },
                    win_border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
                    hl = { border = "FloatBorder", },
                    height = '0.8',
                    width = '0.60',
                    col = 0.48,
                },
                previewers = {
                    bat = {
                        cmd  = "bat",
                        args = "--style=plain --color=always",
                    },
                },
                files      = {
                    file_icons = false,
                    git_icons = false,
                    color_icons = false,
                    cmd = os.getenv("FZF_DEFAULT_COMMAND"),
                },
                actions    = {
                    files = {
                        ["default"] = actions.file_edit_or_qf,
                        ["ctrl-x"] = actions.file_vsplit,
                        ["ctrl-s"] = actions.file_split,
                        ["ctrl-t"] = false,
                        ["alt-q"] = actions.file_sel_to_qf,
                        ["alt-l"] = actions.file_sel_to_ll,
                    },
                    buffers = {
                        ["default"] = actions.buf_edit,
                        ["ctrl-s"] = actions.buf_split,
                        ["ctrl-x"] = actions.buf_vsplit,
                        ["ctrl-t"] = false,
                    }
                },
            })

            vim.keymap.set("n", " fl", fzf.blines, {})
            vim.keymap.set("n", "<C-t>", function()
                fzf.fzf_exec(os.getenv("FZF_DEFAULT_COMMAND"), {
                    preview = "bat --wrap=auto --style=plain --color=always --line-range=1:25 {} ",
                    actions = {
                        ["default"] = actions.file_edit_or_qf,
                        ["ctrl-x"] = actions.file_vsplit,
                        ["ctrl-s"] = actions.file_split,
                        ["ctrl-t"] = false,
                        ["alt-q"] = actions.file_sel_to_qf,
                        ["alt-l"] = actions.file_sel_to_ll,
                    }
                })
            end, {})

            local au = vim.api.nvim_create_autocmd

            local function augroup(name, fnc)
                fnc(vim.api.nvim_create_augroup(name, { clear = true }))
            end

            augroup("FzfLuaCtrlC", function(g)
                au("FileType",
                    {
                        group = g,
                        pattern = "fzf",
                        callback = function(e)
                            vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = e.buf, silent = true })
                        end,
                    })
            end)
        end,

    },
    {
        'smoka7/hop.nvim',
        version = false,
        lazy = true,
        keys = { "v", "d", "<M-c>" },
        opts = { keys = 'werasdfcvjlk', quit_key = '<C-c>', jump_on_sole_occurrence = true },
        config = function(_, opts)
            local hop = require('hop')
            hop.setup(opts)
            vim.keymap.set('', '<M-c>', function() require("hop").hint_words() end,
                { remap = true })
            vim.api.nvim_set_hl(0, "HopNextKey", { fg = "#242424", bg = "#7daea3" })
            vim.api.nvim_set_hl(0, "HopNextKey1", { fg = "#242424", bg = "#7daea3" })
            vim.api.nvim_set_hl(0, "HopNextKey2", { fg = "#242424", bg = "#D8A657" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        version      = false,
        lazy         = true,
        event        = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects"
        },
        opts         = {
            highlight = {
                enable = false,
                additional_vim_regex_highlighting = false,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ic"] = "@call.inner",
                        ["ac"] = "@call.inner",
                    }
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                    },
                },
            },
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "cpp", "latex", "css", "go", "python", "bash",
                "diff", "yaml", "markdown", "ini", "json", "toml", "norg" },
        },
        config       = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
            vim.treesitter.language.register("bash", "zsh")
            vim.cmd("TSEnable highlight")
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        version = false,
        lazy    = true,
        event   = "InsertEnter",
        config  = function(_, opts)
            local ls = require("luasnip")
            ls.setup(opts)
            require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
            ls.config.set_config({
                history = true,
                updateevents = "TextChanged,TextChangedI",
                enable_autosnippets = true,
            })
        end,
    },
    {
        "NvChad/nvim-colorizer.lua",
        version = false,
        lazy    = true,
        event   = "VeryLazy",
        ft      = { "css", "yaml", "javascript", "xml", "lua" },
        keys    = " co",
        opts    = {
            filetypes = { "css", "yaml", "javascript", "xml", "lua" },
            user_default_options = {
                names = false,
            },
        },
        config  = function(_, opts)
            local c = require("colorizer")
            c.setup(opts)
            vim.keymap.set("n", " co", ":ColorizerAttachToBuffer<CR>")
            local bufnr = vim.api.nvim_get_current_buf()
            if bufnr and not c.is_buffer_attached(bufnr) then
                c.attach_to_buffer(bufnr)
            end
        end,
    },
    {
        "kylechui/nvim-surround",
        version = false,
        keys    = { 'v', 'V', 'ys', 'cs', 'ds' },
        opts    = {},
        config  = function(opts)
            require("nvim-surround").setup(opts)
        end
    },
    {
        "hrsh7th/nvim-cmp",
        version      = false,
        event        = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'saadparwaiz1/cmp_luasnip',
        },
        config       = function(_, opts)
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local types = require("cmp.types")
            cmp.setup({
                completion = {
                    autocomplete = {
                        types.cmp.TriggerEvent.InsertEnter,
                        types.cmp.TriggerEvent.TextChanged
                    }
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end
                },
                sources = {
                    { name = 'luasnip', keyword_length = 3 },
                    { name = 'nvim_lsp' },
                    { name = 'buffer',  keyword_length = 2 },
                    { name = 'path',    keyword_length = 2 },
                },
                window = {
                    completion = {
                        border = 'single',
                        winhighlight = "FloatBorder:FloatBorder,CursorLine:PmenuSel",
                        scrollbar = false,
                    },
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
                    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.abort(),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                experimental = {
                    ghost_text = { inline = true },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        version = false,
        lazy    = true,
        event   = { "BufReadPost", "BufNewFile", "BufWritePre" },
        config  = function()
            local lspconfig = require("lspconfig")
            vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
            vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
                { border = 'single' })
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<space>ca',
                        function() vim.lsp.buf.code_action { only = { "quickfix" } } end, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

                    vim.keymap.set('n', '<space>f', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)
                end,
            })
            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = {
                                snippetSupport = false
                            },
                        },
                    },
                },
                cmd = { "gopls" },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                }
            })
            lspconfig.pyright.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
            lspconfig.lua_ls.setup({
                on_init = function(client)
                    local path = client.workspace_folders[1].name
                    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                            Lua = {
                                runtime = {
                                    -- Tell the language server which version of Lua you're using
                                    -- (most likely LuaJIT in the case of Neovim)
                                    version = 'LuaJIT'
                                },
                                -- Make the server aware of Neovim runtime files
                                workspace = {
                                    checkThirdParty = false,
                                    library = {
                                        vim.env.VIMRUNTIME
                                        -- "${3rd}/luv/library"
                                        -- "${3rd}/busted/library",
                                    }
                                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                                    -- library = vim.api.nvim_get_runtime_file("", true)
                                }
                            }
                        })
                        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                    end
                    return true
                end
            })
            lspconfig.bashls.setup({})
            lspconfig.eslint.setup({
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        command = "EslintFixAll",
                    })
                end,
            })
        end,
    },
    {
        "numToStr/Comment.nvim",
        version = false,
        lazy    = true,
        keys    = { 'V', 'v', 'gc' },
        config  = function()
            require('Comment').setup()
        end,
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {
            map_c_w = true,
            fast_wrap = {},
        },
        config = function(_, opts)
            local npairs = require('nvim-autopairs')
            npairs.setup(opts)
            local Rule = require('nvim-autopairs.rule')
            local cond = require('nvim-autopairs.conds')
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )

            npairs.add_rule(Rule("<", ">", "lua"))
            -- npairs.add_rule(
            --     Rule('"', '"')
            --     :with_pair(cond.not_before_regex("%w"))
            -- )


            local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
            npairs.add_rules {
                -- Rule for a pair with left-side ' ' and right side ' '
                Rule(' ', ' ')
                -- Pair will only occur if the conditional function returns true
                    :with_pair(function(opts)
                        -- We are checking if we are inserting a space in (), [], or {}
                        local pair = opts.line:sub(opts.col - 1, opts.col)
                        return vim.tbl_contains({
                            brackets[1][1] .. brackets[1][2],
                            brackets[2][1] .. brackets[2][2],
                            brackets[3][1] .. brackets[3][2]
                        }, pair)
                    end)
                    :with_move(cond.none())
                    :with_cr(cond.none())
                -- We only want to delete the pair of spaces when the cursor is as such: ( | )
                    :with_del(function(opts)
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local context = opts.line:sub(col - 1, col + 2)
                        return vim.tbl_contains({
                            brackets[1][1] .. '  ' .. brackets[1][2],
                            brackets[2][1] .. '  ' .. brackets[2][2],
                            brackets[3][1] .. '  ' .. brackets[3][2]
                        }, context)
                    end)
            }
            -- For each pair of brackets we will add another rule
            for _, bracket in pairs(brackets) do
                npairs.add_rules {
                    -- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
                    Rule(bracket[1] .. ' ', ' ' .. bracket[2])
                        :with_pair(cond.none())
                        :with_move(function(opts) return opts.char == bracket[2] end)
                        :with_del(cond.none())
                        :use_key(bracket[2])
                    -- Removes the trailing whitespace that can occur without this
                        :replace_map_cr(function(_) return '<C-c>2xi<CR><C-c>O' end)
                }
            end
        end,
    },
    {
        "github/copilot.vim",
        version = false,
        lazy    = true,
        cmd     = "Copilot",
        config  = function()
            require("Copilot").setup()
        end,
    },
    {
        'echasnovski/mini.align',
        version = false,
        keys    = { "V", "v" },
        config  = function()
            require('mini.align').setup({})
        end
    },
    {
        'numToStr/Navigator.nvim',
        version = false,
        event   = "VeryLazy",
        config  = function()
            require('Navigator').setup()
            vim.keymap.set({ 'i', 'n', 't' }, '<A-h>', '<CMD>NavigatorLeft<CR>')
            vim.keymap.set({ 'i', 'n', 't' }, '<A-l>', '<CMD>NavigatorRight<CR>')
            vim.keymap.set({ 'i', 'n', 't' }, '<A-k>', '<CMD>NavigatorUp<CR>')
            vim.keymap.set({ 'i', 'n', 't' }, '<A-j>', '<CMD>NavigatorDown<CR>')
            -- vim.keymap.set({ 'n', 't' }, '<A-p>', '<CMD>NavigatorPrevious<CR>')
        end
    },
    -- {
    --     "folke/flash.nvim",
    --     version = false,
    --     lazy    = true,
    --     keys    = { 'd', 'v', 'f', 'F', 't', 'T', ';', ',' },
    --     keys    = {
    --         { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    --     },
    --     opts    = {
    --         labels  = "acdefjklrsvw",
    --         forward = false,
    --         label   = {
    --             uppercase = false,
    --         },
    --         modes   = {
    --             char = {
    --                 enabled = true,
    --                 highlight = { backdrop = false },
    --             },
    --             search = {
    --                 enabled = false,
    --             }
    --         }
    --     },
    --     config  = function(_, opts)
    --         local flash = require('flash')
    --         flash.setup(opts)
    --         vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#242424", bg = "#D8A657" })
    --         vim.api.nvim_set_hl(0, "FlashCursor", { fg = "#D8A657", bg = "#242424" })
    --         vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#242424", bg = "#7DAEA3" })
    --     end,
    -- },
    {
        "backdround/improved-ft.nvim",
        version = false,
        lazy    = true,
        keys    = { "f", "t", "F", "T", ";", "," },
        opts    = {
            use_default_mappings = true,
            use_relative_repetition = true,
        },
        config  = function(_, opts)
            local ft = require("improved-ft")
            ft.setup(opts)
        end,
    },
}
