local config = function()
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
        performance = {
            max_view_entries = 4
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end
        },
        sources = {
            { name = 'path' },
            { name = 'luasnip', keyword_length = 3 },
            { name = 'nvim_lsp' },
            { name = 'buffer',  keyword_length = 2 },
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
end


return {
    "hrsh7th/nvim-cmp",
    version      = false,
    event        = { "InsertEnter" },
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
    },
    config       = config,
}
