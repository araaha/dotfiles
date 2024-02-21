return {
    "echasnovski/mini.align",
    version = false,
    lazy    = true,
    keys    = {
        { "ga", mode = { "n", "v", "o" } },
    },
    config  = function()
        require("mini.align").setup()
    end,
}
