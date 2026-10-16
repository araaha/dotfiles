local M = {}

function M.setup()
    if M.loaded then return end
    local ok, ui = pcall(require, "vim._core.ui2")
    if not ok or not ui.cmd then return end
    M.loaded = true

    local api = vim.api
    local border = require("ui.style").border
    local saved, saved_win, menu_pos

    local function restore()
        if not saved then return end
        if api.nvim_win_is_valid(saved_win) then
            api.nvim_win_set_config(saved_win, saved)
        end
        vim.g.ui_cmdline_pos = menu_pos
        saved, saved_win, menu_pos = nil, nil, nil
    end

    local function center()
        local win = ui.wins.cmd
        if ui.cmd.level == 0 or not api.nvim_win_is_valid(win) then return end
        local cmdtype = vim.fn.getcmdtype()
        if cmdtype == "/" or cmdtype == "?" then
            restore()
            return
        end
        if saved_win ~= win then
            local cfg = api.nvim_win_get_config(win)
            saved = {
                relative = cfg.relative, anchor = cfg.anchor,
                row = cfg.row, col = cfg.col, width = cfg.width, border = cfg.border,
            }
            saved_win, menu_pos = win, vim.g.ui_cmdline_pos
        end

        local width = math.max(1, math.min(80, vim.o.columns - 2, math.floor(vim.o.columns * 0.6)))
        api.nvim_win_set_config(win, { width = width, border = border })
        local height = math.max(1, math.min(vim.o.lines - 2, api.nvim_win_text_height(win, {}).all))
        local row = math.max(0, math.floor((vim.o.lines - height - 2) / 2))
        local col = math.max(0, math.floor((vim.o.columns - width - 2) / 2))
        api.nvim_win_set_config(win, {
            relative = "editor", anchor = "NW", row = row, col = col, height = height,
        })
        vim.g.ui_cmdline_pos = { row + height + 2, col + 2 }
        vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
            vim.o.cmdheight = 0
        end)
    end

    local show, hide = ui.cmd.cmdline_show, ui.cmd.cmdline_hide
    ui.cmd.cmdline_show = function(content, pos, firstc, ...)
        if firstc == "/" or firstc == "?" then restore() end
        show(content, pos, firstc, ...)
        center()
    end
    ui.cmd.cmdline_hide = function(...)
        hide(...)
        if ui.cmd.level == 0 then restore() end
    end

    api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
        group = api.nvim_create_augroup("CenteredCmdline", { clear = true }),
        callback = function() vim.schedule(center) end,
    })
end

return M
