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

remember()


au({ 'BufReadPost' }, {
    callback = function(args)
        local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
        local not_commit = vim.b[args.buf].filetype ~= 'commit'

        if valid_line and not_commit then
            vim.cmd([[normal! g`"]])
        end
    end,
})

au('Filetype', {
    pattern = "help",
    callback = function()
        if vim.fn.winheight(0) < 16 then
            vim.cmd("resize 7.5")
        else
            vim.cmd("resize 15")
        end
    end,
})
