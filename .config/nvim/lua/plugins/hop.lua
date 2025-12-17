return {
    "wsdjeg/hop.nvim",
    cmd = "Hop",
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
    },
    opts = {
        keys = "werasdfcvjlk",
        quit_key = "<C-c>",
        repeat_key = "<BS>",
        jump_on_sole_occurrence = true,
        dim_unmatched = false
    },
}
