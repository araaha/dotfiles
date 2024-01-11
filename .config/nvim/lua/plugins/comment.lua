return {
    "numToStr/Comment.nvim",
    version = false,
    lazy    = true,
    keys    = { 'V', 'v', 'gc' },
    config  = function()
        local ft = require('Comment.ft')
        ft.toml = '#%s'
        require('Comment').setup()
    end,
}
