local M = {}

local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }
function M.navigate(direction)
    local previous = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(direction)

    -- Enter terminal input when the destination is a Neovim terminal.
    if vim.bo.buftype == "terminal" then
        vim.cmd.startinsert()
    end
    if vim.api.nvim_get_current_win() ~= previous then return end
    if not vim.env.TMUX or not vim.env.TMUX_PANE or vim.fn.executable("tmux") ~= 1 then return end

    -- Target this Neovim's pane, even if another client changes its selection.
    vim.system({ "tmux", "select-pane", "-t", vim.env.TMUX_PANE, "-" .. tmux_directions[direction] },
        { text = true }, function(result)
            if result.code ~= 0 then
                vim.schedule(function()
                    vim.notify("tmux navigation: " .. vim.trim(result.stderr or "pane selection failed"),
                        vim.log.levels.WARN)
                end)
            end
        end)
end


return M
