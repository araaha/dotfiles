return {
    "smjonas/inc-rename.nvim",
    opts = {
        cmd_name = "Rename"
    },
    keys = {
        {
            "<leader>rr",
            function()
                return ":Rename " .. vim.fn.expand("<cword>")
            end,
            expr = true
        },
        {
            "<leader>rn",
            ":Rename "
        }
    },
}
