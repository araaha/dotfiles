local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au('TextYankPost',
    {
        group = ag('yank_highlight', {}),
        callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 450 } end,
    }
)

local remember = function()
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) <= vim.fn.line('$')
    local not_commit = vim.b[0].filetype ~= 'commit'

    if valid_line and not_commit then
        vim.cmd([[normal! g`"zz]])
    end
end

vim.defer_fn(function()
    remember()
end, 10)

au({ 'BufReadPost' }, {
    callback = function(args)
        local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) <= vim.fn.line('$')
        local not_commit = vim.b[args.buf].filetype ~= 'commit'

        if valid_line and not_commit then
            vim.cmd([[normal! g`"zz]])
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
            vim.cmd.only()
            vim.bo.buflisted = true
        end
    end,
})
