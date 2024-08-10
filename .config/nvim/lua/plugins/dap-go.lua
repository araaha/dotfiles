return {
    "leoluz/nvim-dap-go",
    version      = false,
    lazy         = true,
    opts         = {},
    keys         = {
        { "<Leader>di",  "<cmd>DapStepInto<cr>", mode = "n" },
        { "<Leader>dtb", "<cmd>DapStepInto<cr>", mode = "n" },
    },
    dependencies = "mfussenegger/nvim-dap",
}

