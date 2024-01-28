local opts = {
    mappings = {
        increment = "<C-a>",
        decrement = "<C-x>"
    },
    additions = {
        { "sh", "bash", "zsh" }
    }
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
