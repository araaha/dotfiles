return {
    "numToStr/Comment.nvim",
    version = false,
    lazy    = true,
    keys    = {
        { "gc", mode = { "n", "v", "o" } },
        { "gb", mode = { "n", "v", "o" } }
    },
    config  = function()
        require("Comment").setup()
    end,
}
