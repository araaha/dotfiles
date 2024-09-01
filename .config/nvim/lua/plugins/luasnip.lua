return {
    "L3MON4D3/LuaSnip",
    build  = "make install_jsregexp",
    lazy   = true,
    event  = "InsertEnter",
    opts   = {},
    config = function()
        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
        require("luasnip").config.set_config({
            history = true,
            updateevents = "TextChangedI",
            enable_autosnippets = true,
        })
    end
}
