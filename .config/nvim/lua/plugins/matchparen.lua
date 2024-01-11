local opts = {
    debounce_time = 10,
}

return {
    "monkoose/matchparen.nvim",
    version = false,
    lazy    = true,
    event   = "InsertEnter",
    config  = function()
        require('matchparen').setup(opts)
    end,
}
