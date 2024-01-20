local opts = {
    filetypes = { "css", "yaml", "javascript", "xml", "lua", "toml" },
    user_default_options = {
        names = false,
        rgb_fn = true
    },
}

return {
    "NvChad/nvim-colorizer.lua",
    version = false,
    lazy    = true,
    keys    = { { " co", "<cmd>ColorizerToggle<cr>", mode = "n" } },
    ft      = { "css", "yaml", "javascript", "xml", "lua", "toml" },
    config  = function()
        local c = require("colorizer")
        c.setup(opts)
    end,
}
