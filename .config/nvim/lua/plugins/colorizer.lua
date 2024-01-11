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
    ft      = { "css", "yaml", "javascript", "xml", "lua", "toml" },
    event   = "VeryLazy",
    keys    = { { " co", "<cmd>ColorizerAttachToBuffer<cr>", mode = "n" } },
    config  = function()
        local c = require("colorizer")
        c.setup(opts)
    end,
}
