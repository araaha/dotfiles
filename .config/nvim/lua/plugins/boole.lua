local opts = {
    mappings = {
        increment = "<C-a>",
        decrement = "<C-x>"
    },
}
return {
    "nat-418/boole.nvim",
    version = false,
    keys    = { "<C-a>", "<C-x>" },
    opts    = opts,
    config  = function()
        require("boole").setup(opts)
    end,
}
