return {
    "L3MON4D3/LuaSnip",
    build  = "make install_jsregexp",
    lazy   = true,
    event  = "InsertEnter",
    opts   = {},
    config = function()
        local luasnip = require("luasnip")

        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
        luasnip.config.set_config({
            history = true,
            updateevents = "TextChangedI",
            enable_autosnippets = true,
        })
        -- -- Unlink snippet if you leave insert mode
        -- vim.api.nvim_create_autocmd("ModeChanged", {
        --     pattern = { "i:n", "s:n" }, -- from insert or select mode to normal
        --     callback = function()
        --         if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        --             and not luasnip.session.jump_active then
        --             luasnip.unlink_current()
        --         end
        --     end,
        -- })
    end
}
