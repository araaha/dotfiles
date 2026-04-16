return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    opts  = function()
        require("luasnip.loaders.from_lua").load({
            paths = vim.fn.stdpath("config") .. "/snippets"
        })
        return {
            enable_autosnippets = true
        }
    end
}
