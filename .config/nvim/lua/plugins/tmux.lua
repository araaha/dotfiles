return {
    "nathom/tmux.nvim",
    version = false,
    keys    = {
        {
            "<M-h>",
            function() require("tmux").move_left() end,
            mode = ""
        },
        {
            "<M-j>",
            function() require("tmux").move_down() end,
            mode = ""
        },
        {
            "<M-k>",
            function() require("tmux").move_up() end,
            mode = ""
        },
        {
            "<M-l>",
            function() require("tmux").move_right() end,
            mode = ""
        },
    },
}
