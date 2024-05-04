local opts = {
    keys = "werasdfcvjlk",
    quit_key = "<C-c>",
    jump_on_sole_occurrence = true,
    dim_unmatched = false
}

return {
    "smoka7/hop.nvim",
    version = false,
    lazy = true,
    keys = {
        {
            "<M-c>",
            "<cmd>HopWord<cr>",
            mode = { "n", "x", "o" }
        },
    },
    opts = opts,
}
