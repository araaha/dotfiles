-- Private Neovim APIs are optional and may change between releases.
local ok_ui, ui2 = pcall(require, "vim._core.ui2")
local ok_msgs, msgs = pcall(require, "vim._core.ui2.messages")
if not ok_ui or not ok_msgs or type(ui2.enable) ~= "function" or type(msgs.set_pos) ~= "function" then
    return
end
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
    orig_set_pos(tgt)
    if (tgt == "msg" or tgt == nil) and ui2.wins and ui2.wins.msg and vim.api.nvim_win_is_valid(ui2.wins.msg) then
        pcall(vim.api.nvim_win_set_config,
            ui2.wins.msg,
            {
                relative = "editor",
                anchor = "SE",
                row = vim.o.lines - 1,
                col = 0,
                border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
            })
    end
end
pcall(ui2.enable, {
    enable = true,          -- Whether to enable or disable the UI.
    msg = {                 -- Options related to the message module.
        targets = 'msg',
        cmd = {             -- Options related to messages in the cmdline window.
            height = 0.5    -- Maximum height while expanded for messages beyond 'cmdheight'.
        },
        dialog = {          -- Options related to dialog window.
            height = 0.5,   -- Maximum height.
        },
        msg = {             -- Options related to msg window.
            height = 0.5,   -- Maximum height.
            timeout = 1000, -- Time a message is visible in the message window.
        },
        pager = {           -- Options related to message window.
            height = 1,     -- Maximum height.
        },
    },
})
