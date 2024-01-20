return {
    "numToStr/Comment.nvim",
    version = false,
    lazy    = true,
    keys    = { 'V', 'v', 'gc' },
    config  = function()
        require('Comment').setup()
    end,
}
