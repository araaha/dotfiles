local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au("TextYankPost",
    {
        group = ag("yank_highlight", {}),
        callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 450 }) end,
    }
)

local remember = function()
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) <= vim.fn.line("$")
    local not_commit = vim.b[0].filetype ~= "commit"

    if valid_line and not_commit then
        vim.cmd([[normal! g`"zz]])
    end
end

au({ "BufRead" }, {
    callback = remember,
})

au({ "CursorMoved" }, {
    callback = function()
        vim.cmd("norm! zz")
    end
})

au({ "TermOpen" }, {
    callback = function()
        vim.cmd.startinsert()
    end
})

au("TermClose", {
    callback = function(args)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
                vim.api.nvim_buf_delete(args.buf, { force = true })
            end
        end)
    end,
})


au({ "CmdLineEnter" }, {
    callback = function()
        vim.opt.smartcase = false
    end
})

au({ "CmdLineLeave" }, {
    callback = function()
        vim.opt.smartcase = true
    end
})

au('BufReadPre', {
    callback = function()
        local max_filesize = 100 * 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
            vim.b.minihipatterns_disable = true
        end
    end
})
