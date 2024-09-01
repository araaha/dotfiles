return {
    "araaha/hop.nvim",
    keys = {
        {
            "<M-c>",
            "<cmd>HopWord<cr>",
            mode = { "n", "x", "o" }
        },
        {
            "<M-y>",
            "<cmd>HopYankChar1<cr>",
            mode = { "n", "x", "o" }
        },
        {
            "<M-f>",
            function()
                require("hop").hint_patterns({}, "\\~*/.*")
                vim.cmd("norm gf")
            end,
            mode = { "n", "x", "o" }
        },
    },
    opts = {
        keys = "werasdfcvjlk",
        quit_key = "<C-c>",
        repeat_key = "<BS>",
        jump_on_sole_occurrence = true,
        dim_unmatched = false
    },
}
