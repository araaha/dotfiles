return {
    "saghen/blink.cmp",
    event = "InsertEnter",
    enabled = true,
    version = "v0.*",
    opts = {
        keymap = {
            ["<C-n>"]      = { "show", "select_next" },
            ["<C-p>"]      = { "show", "select_prev" },
            ["<C-e>"]      = { "hide" },
            -- accept = { "<C-Space>" },
            ["<C-Space>"]  = { "select_and_accept" },
            ["<Down>"]     = { "select_next" },
            ["<Up>"]       = { "select_prev" },
            ["<PageDown>"] = { "scroll_documentation_down" },
            ["<PageUp>"]   = { "scroll_documentation_up" },
            ["<Tab>"]      = { "snippet_forward" },
            ["<S-Tab>"]    = { "snippet_backward" }
        },
        fuzzy = {
            -- frencency tracks the most recently/frequently used items and boosts the score of the item
            use_frecency = true,
            -- proximity bonus boosts the score of items matching nearby words
            use_proximity = true,
            use_typo_resistance = false,
            max_items = 50,
            -- controls which sorts to use and in which order, these three are currently the only allowed options
            sorts = { 'label', 'kind', 'score' },
        },
        sources = {
            -- list of enabled providers
            completion = {
                -- path disabled
                enabled_providers = { 'lsp', 'snippets', 'buffer' },
            },

            -- Please see https://github.com/Saghen/blink.compat for using `nvim-cmp` sources
            providers = {
                lsp = {
                    name = 'LSP',
                    module = 'blink.cmp.sources.lsp',
                    enabled = true,           -- whether or not to enable the provider
                    transform_items = nil,    -- function to transform the items before they're returned
                    should_show_items = true, -- whether or not to show the items
                    max_items = 10,           -- maximum number of items to return
                    min_keyword_length = 0,   -- minimum number of characters to trigger the provider
                    fallback_for = {},        -- if any of these providers return 0 items, it will fallback to this provider
                    score_offset = 0,         -- boost/penalize the score of the items
                    override = nil,           -- override the source's functions
                },
                path = {
                    name = 'Path',
                    module = 'blink.cmp.sources.path',
                    score_offset = 3,
                    opts = {
                        trailing_slash = false,
                        label_trailing_slash = true,
                        get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
                        show_hidden_files_by_default = true,
                    }
                },
                snippets = {
                    name = 'Snippets',
                    module = 'blink.cmp.sources.snippets',
                    score_offset = -3,
                    opts = {
                        friendly_snippets = false,
                        search_paths = { vim.fn.stdpath('config') .. '/snippets' },
                        global_snippets = { 'all' },
                        extended_filetypes = {},
                        ignored_filetypes = {},
                    }
                },
                buffer = {
                    name = 'Buffer',
                    module = 'blink.cmp.sources.buffer',
                    max_items = 10,
                    fallback_for = { 'lsp' },
                },
            },
        },
        windows = {
            autocomplete = {
                max_items = 50,
                draw = {
                    gap = 1,
                    padding = { 0, 0 },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx) return " " .. ctx.kind_icon .. ctx.icon_gap .. " " end,
                        },
                        kind = {
                            ellipsis = false,
                            width = { fill = true },
                            text = function(ctx) return ctx.kind end,
                        },
                        label = {
                            width = { fill = true, max = 30 },
                            text = function(ctx) return ctx.label .. ctx.label_detail end,
                            ellipsis = false,
                            highlight = function(ctx)
                                -- label and label details
                                local highlights = {
                                    { 0, #ctx.label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
                                }
                                if ctx.label_detail then
                                    table.insert(highlights,
                                        { #ctx.label, #ctx.label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
                                end

                                -- characters matched on the label by the fuzzy matcher
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                                end

                                return highlights
                            end,
                        },
                    }
                }
                -- draw = function(ctx)
                --     local icon = ctx.kind_icon
                --
                --     return {
                --         { " " .. icon .. " ", hl_group = "BlinkCmpKind" .. ctx.kind },
                --         {
                --             " " .. ctx.item.label,
                --             max_width = 30,
                --         },
                --     }
                -- end,
            },
            documentation = {
                border = "single",
                auto_show = true,
                auto_show_delay_ms = 500,
                update_delay_ms = 30,
            },
            signature_help = {
                min_width = 1,
                max_width = 100,
                max_height = 10,
                border = 'single',
                winhighlight = 'Normal:Pmenu,FloatBorder:GruvboxBlue',
            },
            ghost_text = {
                enabled = true
            }
        },
        kind_icons = {
            Text = "󰉿",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰅲",
        },

        accept = { auto_brackets = { enabled = true } },

        trigger = { signature_help = { enabled = false } }
    }
}
