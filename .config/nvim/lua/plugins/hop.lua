local opts = {
    keys = "werasdfcvjlk",
    quit_key = "<C-c>",
    jump_on_sole_occurrence = true
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
    config = function()
        local hop = require("hop")
        hop.setup(opts)
    end,
}
