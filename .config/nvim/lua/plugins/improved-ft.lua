local opts = {
    use_default_mappings = true,
    use_relative_repetition = true,
}

return {
    "backdround/improved-ft.nvim",
    version = false,
    lazy    = true,
    keys    = { { "f", mode = { "n", "v" } }, { "t", mode = { "n", "v" } }, "F", "T", ";", "," },
    opts    = opts
}
