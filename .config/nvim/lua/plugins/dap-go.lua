return {
    "leoluz/nvim-dap-go",
    version      = false,
    lazy         = true,
    opts         = {},
    keys         = "<Leader>dap",
    dependencies = "mfussenegger/nvim-dap",
    config       = function()
        require("dap-go").setup()
        vim.keymap.set("n", " di", "<cmd>DapStepInto<cr>", {})
    end
}
