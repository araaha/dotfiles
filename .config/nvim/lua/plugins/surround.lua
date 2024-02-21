return {
    "kylechui/nvim-surround",
    version = false,
    keys    = {
        { "S", mode = "v" },
        "ys",
        "cs",
        "ds"
    },
    opts    = {},
    config  = function(opts)
        require("nvim-surround").setup(opts)
    end
}
