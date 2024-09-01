return {
    "araaha/tmux.nvim",
    keys = {
        {
            "<M-h>",
            "<cmd>lua require('tmux').move_left()<cr>",
            mode = { "n" }
        },
        {
            "<M-l>",
            "<cmd>lua require('tmux').move_right()<cr>",
            mode = { "n" }
        },
        {
            "<M-j>",
            "<cmd>lua require('tmux').move_down()<cr>",
            mode = { "n" }
        },
        {
            "<M-k>",
            "<cmd>lua require('tmux').move_up()<cr>",
            mode = { "n" }
        },
        {
            "<M-h>",
            "<cmd>lua require('tmux').move_left()<cr>",
            mode = { "t" }
        },
        {
            "<M-l>",
            "<cmd>lua require('tmux').move_right()<cr>",
            mode = { "t" }
        },
        {
            "<M-j>",
            "<cmd>lua require('tmux').move_down()<cr>",
            mode = { "t" }
        },
        {
            "<M-k>",
            "<cmd>lua require('tmux').move_up()<cr>",
            mode = { "t" }
        },
        {
            "<M-h>",
            "<C-o><cmd>lua require('tmux').move_left()<cr>",
            mode = "i"
        },
        {
            "<M-j>",
            "<C-o><cmd>lua require('tmux').move_down()<cr>",
            mode = "i"
        },
        {
            "<M-k>",
            "<C-o><cmd>lua require('tmux').move_up()<cr>",
            mode = "i"
        },
        {
            "<M-l>",
            "<C-o><cmd>lua require('tmux').move_right()<cr>",
            mode = "i"
        },
    }
}
