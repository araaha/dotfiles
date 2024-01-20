local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au('TextYankPost',
    {
        group = ag('yank_highlight', {}),
        callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 450 } end,
    }
)

local remember = function()
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
    local not_commit = vim.b[0].filetype ~= 'commit'

    if valid_line and not_commit then
        vim.cmd([[normal! g`"]])
    end
end

vim.defer_fn(function()
    remember()
end, 2)

au({ 'BufReadPost' }, {
    callback = function(args)
        local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
        local not_commit = vim.b[args.buf].filetype ~= 'commit'

        if valid_line and not_commit then
            vim.cmd([[normal! g`"]])
        end
    end,
})

au({ 'BufEnter' }, {
    callback = function()
        vim.cmd("norm! zz")
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.bo.filetype == "help" then
            -- close the original window
            local original_win = vim.fn.win_getid(vim.fn.winnr('#'))
            local help_win = vim.api.nvim_get_current_win()
            if original_win ~= help_win then
                vim.api.nvim_win_close(original_win, false)
            end
        end
    end,
})
