return {
    "nathom/tmux.nvim",
    version = false,
    keys    = {
        "<M-h>",
        "<M-j>",
        "<M-k>",
        "<M-l>"
    },
    config  = function()
        local tmux = require("tmux")
        local map = vim.keymap.set
        map("", "<M-h>", function() tmux.move_left() end, {})
        map("", "<M-j>", function() tmux.move_down() end, {})
        map("", "<M-k>", function() tmux.move_up() end, {})
        map("", "<M-l>", function() tmux.move_right() end, {})
    end
}
