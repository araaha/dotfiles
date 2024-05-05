return {
    "hrsh7th/nvim-cmp",
    version      = false,
    event        = { "InsertEnter" },
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
    },
    config       = function()
        local luasnip = require("luasnip")
        local cmp = require("cmp")
        local types = require("cmp.types")

        local default_cmp_sources = cmp.config.sources({
            { name = "path" },
            { name = "luasnip", keyword_length = 3 },
            { name = "nvim_lsp" },
        })

        local bufIsBig = function(bufnr)
            local max_filesize = 200 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
            if ok and stats and stats.size > max_filesize then
                return true
            else
                return false
            end
        end

        local buffer_sources = function()
            local sources = default_cmp_sources
            if not bufIsBig(0) then
                sources[#sources + 1] = { name = "buffer", group_index = 4 }
            end
            cmp.setup.buffer {
                sources = sources
            }
        end

        buffer_sources()


        cmp.setup({
            completion = {
                autocomplete = {
                    types.cmp.TriggerEvent.InsertEnter,
                    types.cmp.TriggerEvent.TextChanged
                }
            },
            performance = {
                max_view_entries = 4
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end
            },
            window = {
                completion = {
                    border = "single",
                    winhighlight = "FloatBorder:FloatBorder,CursorLine:StatusLine",
                    side_padding = 0,
                    scrollbar = false,
                },
                documentation = {
                    border = "single",
                    winhighlight = "FloatBorder:FloatBorder,CursorLine:StatusLine",
                }
            },
            mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
                ["<C-n>"] = cmp.mapping.select_next_item(select_opts),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.abort(),
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
            formatting = {
                fields = { "kind", "abbr" },
                format = function(entry, vim_item)
                    local kind_icons = {
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
                    }
                    vim_item.kind = string.format(' %s ', kind_icons[vim_item.kind])
                    return vim_item
                end
            },
        })
    end
}
