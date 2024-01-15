return {
    "kylechui/nvim-surround",
    version = false,
    keys    = {
        'v',
        'V',
        'ys',
        'cs',
        'ds'
    },
    opts    = {},
    config  = function(opts)
        require("nvim-surround").setup(opts)
    end
}
