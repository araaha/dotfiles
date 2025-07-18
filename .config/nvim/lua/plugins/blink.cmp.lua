return {
    "saghen/blink.cmp",
    event = { "InsertEnter" },
    enabled = true,
    version = "*",
    dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    opts = {
        keymap = {
            ["<C-Space>"]  = { "select_and_accept" },
            ["<C-n>"]      = { "show", "select_next", "fallback" },
            ["<C-p>"]      = { "show", "select_prev", "fallback" },
            ["<C-e>"]      = { "hide", "fallback" },
            ["<C-y>"]      = { "show", "show_documentation", "hide_documentation" },
            ["<Down>"]     = { "select_next", "fallback" },
            ["<Up>"]       = { "select_prev", "fallback" },
            ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
            ["<PageUp>"]   = { "scroll_documentation_up", "fallback" },
            ["<Tab>"]      = { "snippet_forward", "fallback" },
            ["<S-Tab>"]    = { "snippet_backward", "fallback" }
        },
        -- Disables keymaps, completions and signature help for these filetypes
        -- enabled = function() return vim.bo.buftype ~= "prompt" end,

        snippets = { preset = 'luasnip' },

        cmdline = {
            enabled = false
        },

        completion = {
            keyword = {
                -- 'prefix' will fuzzy match on the text before the cursor
                -- 'full' will fuzzy match on the text before *and* after the cursor
                -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
                range = 'prefix',
                -- Regex used to get the text when fuzzy matching
                -- After matching with regex, any characters matching this regex at the prefix will be excluded
            },

            trigger = {
                -- When false, will not show the completion window automatically when in a snippet
                show_in_snippet = true,
                -- When true, will show the completion window after typing a character that matches the `keyword.regex`
                show_on_keyword = true,
                -- When true, will show the completion window after typing a trigger character
                show_on_trigger_character = true,
                -- LSPs can indicate when to show the completion window via trigger characters
                -- however, some LSPs (i.e. tsserver) return characters that would essentially
                -- always show the window. We block these by default.
                show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
                -- When both this and show_on_trigger_character are true, will show the completion window
                -- when the cursor comes after a trigger character after accepting an item
                show_on_accept_on_trigger_character = true,
                -- When both this and show_on_trigger_character are true, will show the completion window
                -- when the cursor comes after a trigger character when entering insert mode
                show_on_insert_on_trigger_character = true,
                -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
                -- the completion window when the cursor comes after a trigger character when
                -- entering insert mode/accepting an item
                show_on_x_blocked_trigger_characters = { "'", '"', '(' },
            },

            list = {
                -- Maximum number of items to display
                max_items = 10,
                -- Controls if completion items will be selected automatically,
                -- and whether selection automatically inserts
                -- Controls how the completion items are selected
                -- 'preselect' will automatically select the first item in the completion list
                -- 'manual' will not select any item by default
                -- 'auto_insert' will not select any item by default, and insert the completion items automatically
                -- when selecting them
                --
                -- You may want to bind a key to the `cancel` command, which will undo the selection
                -- when using 'auto_insert'
                cycle = {
                    -- When `true`, calling `select_next` at the *bottom* of the completion list
                    -- will select the *first* completion item.
                    from_bottom = true,
                    -- When `true`, calling `select_prev` at the *top* of the completion list
                    -- will select the *last* completion item.
                    from_top = true,
                },
            },

            accept = {
                -- Create an undo point when accepting a completion item
                create_undo_point = true,
                -- Experimental auto-brackets support
                auto_brackets = {
                    -- Whether to auto-insert brackets for functions
                    enabled = true,
                    -- Default brackets to use for unknown languages
                    default_brackets = { '(', ')' },
                    -- Overrides the default blocked filetypes
                    override_brackets_for_filetypes = {},
                    -- Synchronously use the kind of the item to determine if brackets should be added
                    kind_resolution = {
                        enabled = false,
                        blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
                    },
                    -- Asynchronously use semantic token to determine if brackets should be added
                    semantic_token_resolution = {
                        enabled = false,
                        blocked_filetypes = {},
                        -- How long to wait for semantic tokens to return before assuming no brackets should be added
                        timeout_ms = 400,
                    },
                },
            },

            menu = {
                enabled = true,
                min_width = 15,
                max_height = 10,
                border = 'none',
                winblend = 0,
                winhighlight =
                'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
                -- Keep the cursor X lines away from the top/bottom of the window
                scrolloff = 2,
                -- Note that the gutter will be disabled when border ~= 'none'
                scrollbar = true,
                -- Which directions to show the window,
                -- falling back to the next direction when there's not enough space
                direction_priority = { 's', 'n' },
                -- Controls how the completion items are rendered on the popup window
                auto_show = true,

                cmdline_position = function()
                    if vim.g.ui_cmdline_pos ~= nil then
                        local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                        return { pos[1] - 1, pos[2] }
                    end
                    local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                    return { vim.o.lines - height, 0 }
                end,

                draw = {
                    -- Aligns the keyword you've typed to a component in the menu
                    -- Left and right padding, optionally { left, right } for different padding on each side
                    padding = { 0, 0 },
                    -- Gap between columns
                    gap = 1,

                    treesitter = { "lsp" },

                    -- Components to render, grouped by column
                    columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                return " " .. ctx.kind_icon .. ctx.icon_gap .. " "
                            end,
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
                                        {
                                            #ctx.label,
                                            #ctx.label +
                                            #ctx.label_detail,
                                            group =
                                            'BlinkCmpLabelDetail'
                                        })
                                end

                                -- characters matched on the label by the fuzzy matcher
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights,
                                        {
                                            idx,
                                            idx + 1,
                                            group =
                                            'BlinkCmpLabelMatch'
                                        })
                                end

                                return highlights
                            end,
                        },

                        label_description = {
                            width = { max = 30 },
                            text = function(ctx) return ctx.label_description end,
                            highlight = 'BlinkCmpLabelDescription',
                        },

                        source_name = {
                            width = { max = 30 },
                            text = function(ctx) return ctx.source_name end,
                            highlight = 'BlinkCmpSource',
                        },
                    },
                },
            },
            documentation = {
                -- Controls whether the documentation window will automatically show when selecting a completion item
                auto_show = true,
                -- Delay before showing the documentation window
                auto_show_delay_ms = 500,
                -- Delay before updating the documentation window when selecting a new item,
                -- while an existing item is still visible
                update_delay_ms = 50,
                -- Whether to use treesitter highlighting, disable if you run into performance issues
                treesitter_highlighting = true,
                window = {
                    min_width = 10,
                    max_width = 60,
                    max_height = 20,
                    border = 'single',
                    winblend = 0,
                    winhighlight =
                    'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
                    -- Note that the gutter will be disabled when border ~= 'none'
                    scrollbar = false,
                    -- Which directions to show the documentation window,
                    -- for each of the possible menu window directions,
                    -- falling back to the next direction when there's not enough space
                    direction_priority = {
                        menu_north = { 'e', 'w', 'n', 's' },
                        menu_south = { 'e', 'w', 's', 'n' },
                    },
                },
            },
            -- Displays a preview of the selected item on the current line
            ghost_text = {
                enabled = true,
            },
        },

        -- Experimental signature help support
        signature = {
            enabled = false,
            trigger = {
                blocked_trigger_characters = {},
                blocked_retrigger_characters = {},
                -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
                show_on_insert_on_trigger_character = true,
            },
            window = {
                min_width = 1,
                max_width = 100,
                max_height = 10,
                border = 'single',
                winblend = 0,
                winhighlight = 'Normal:Pmenu,FloatBorder:GruvboxBlue',
                scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
                -- Which directions to show the window,
                -- falling back to the next direction when there's not enough space,
                -- or another window is in the way
                direction_priority = { 'n', 's' },
                -- Disable if you run into performance issues
                treesitter_highlighting = false,
            },
        },


        fuzzy = {
            -- when enabled, allows for a number of typos relative to the length of the query
            -- disabling this matches the behavior of fzf
            -- frencency tracks the most recently/frequently used items and boosts the score of the item
            use_frecency = true,
            -- proximity bonus boosts the score of items matching nearby words
            use_proximity = false,
            -- controls which sorts to use and in which order, these three are currently the only allowed options
            sorts = { 'score', 'kind', 'label' },

            prebuilt_binaries = {
                -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
                -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
                download = true,
                -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
                -- then the downloader will attempt to infer the version from the checked out git tag (if any).
                --
                -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
                force_version = nil,
                -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
                -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
                -- Check the latest release for all available system triples
                --
                -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
                force_system_triple = nil,
            },
        },

        sources = {
            -- Static list of providers to enable, or a function to dynamically enable/disable providers based on the context
            default = { 'lsp', 'snippets', 'buffer' },

            -- Example dynamically picking providers based on the filetype and treesitter node:
            -- providers = function(ctx)
            --   local node = vim.treesitter.get_node()
            --   if vim.bo.filetype == 'lua' then
            --     return { 'lsp', 'path' }
            --   elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
            --     return { 'buffer' }
            --   else
            --     return { 'lsp', 'path', 'snippets', 'buffer' }
            --   end
            -- end

            -- You may also define providers per filetype
            per_filetype = {
                -- lua = { 'lsp', 'path' },
            },

            -- Function to use when transforming the items before they're returned for all providers
            -- The default will lower the score for snippets to sort them lower in the list
            transform_items = function(_, items)
                for _, item in ipairs(items) do
                    if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
                        item.score_offset = item.score_offset - 3
                    end
                end
                return items
            end,
            -- Minimum number of characters in the keyword to trigger all providers
            -- May also be `function(ctx: blink.cmp.Context): number`
            min_keyword_length = 0,
            -- Example for setting a minimum keyword length for markdown files
            -- min_keyword_length = function()
            --   return vim.bo.filetype == 'markdown' and 2 or 0
            -- end,
        },

        appearance = {
            highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- Will be removed in a future release
            use_nvim_cmp_as_default = false,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
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
        },
    }
}
