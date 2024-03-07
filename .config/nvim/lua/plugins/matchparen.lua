local opts = {
    debounce_time = 10,
}

return {
    "monkoose/matchparen.nvim",
    version = false,
    lazy    = true,
    event   = "InsertEnter",
    opts    = opts
}
