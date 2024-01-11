local opts = {
    use_default_mappings = true,
    use_relative_repetition = true,
}

return {
    "backdround/improved-ft.nvim",
    version = false,
    lazy    = true,
    keys    = { "f", "t", "F", "T", ";", "," },
    config  = function()
        local ft = require("improved-ft")
        ft.setup(opts)
    end,
}
