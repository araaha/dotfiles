local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au('TextYankPost',
    {
        group = ag('yank_highlight', {}),
        pattern = '*',
        callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 450 } end,
    })

au({ 'BufReadPost' }, {
    callback = function(args)
        local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
        local not_commit = vim.b[args.buf].filetype ~= 'commit'

        if valid_line and not_commit then
            vim.cmd([[normal! g`"]])
        end
    end,
})

au({ 'BufEnter', 'BufWinEnter' }, {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
        vim.cmd("norm! zz")
    end,
})
