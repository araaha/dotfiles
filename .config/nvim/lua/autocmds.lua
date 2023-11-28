local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au('TextYankPost',
    {
        group = ag('yank_highlight', {}),
        pattern = '*',
        callback = function() vim.highlight.on_yank { higroup = "CursorLineNr", timeout = 450 } end,
    })

au('BufRead', {
    callback = function(opts)
        au('BufWinEnter', {
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                then
                    vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                end
            end,
        })
    end,
})

au('BufWritePre', {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
        vim.lsp.buf.format()
    end
})

au({ 'BufEnter', 'BufWinEnter' }, {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
        vim.cmd("norm! zz")
    end,
})

au({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.conf",
    callback = function()
        vim.opt.syntax = "toml"
    end
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*",
--     callback = function(args)
--         -- Format code using "conform"
--         require("conform").format({ bufnr = args.buf, async = true }, function()
--             vim.cmd("EslintFixAll")
--         end)
--     end,
-- })
