return {
    "nathom/tmux.nvim",
    version = false,
    keys    = {
        {
            "<M-h>",
            function() require("tmux").move_left() end,
        },
        {
            "<M-h>",
            "<esc><cmd>lua require('tmux').move_left()<cr>a",
            mode = "i"
        },
        {
            "<M-j>",
            function() require("tmux").move_down() end,
        },
        {
            "<M-j>",
            "<esc><cmd>lua require('tmux').move_down()<cr>a",
            mode = "i"
        },
        {
            "<M-k>",
            function() require("tmux").move_up() end,
        },
        {
            "<M-k>",
            "<esc><cmd>lua require('tmux').move_up()<cr>a",
            mode = "i"
        },
        {
            "<M-l>",
            function() require("tmux").move_right() end,
        },
        {
            "<M-l>",
            "<esc><cmd>lua require('tmux').move_right()<cr>a",
            mode = "i"
        },
    },
}
