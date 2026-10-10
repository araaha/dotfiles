local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd
local viewing = ag("UserViewing", { clear = true })
local terminal = ag("UserTerminal", { clear = true })
local search = ag("UserSearch", { clear = true })
local large_files = ag("UserLargeFiles", { clear = true })

au("TextYankPost",
    {
        group = ag("yank_highlight", { clear = true }),
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
    group = viewing,
    callback = remember,
})

au({ "CursorMoved" }, {
    group = viewing,
    callback = function()
        if vim.fn.mode() == "n" then
            vim.cmd("norm! zz")
        end
    end
})

au({ "TermOpen" }, {
    group = terminal,
    callback = function()
        vim.cmd.startinsert()
    end
})

au("TermClose", {
    group = terminal,
    callback = function(args)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
                vim.api.nvim_buf_delete(args.buf, { force = true })
            end
        end)
    end,
})


au({ "CmdLineEnter" }, {
    group = search,
    callback = function()
        vim.opt.smartcase = false
    end
})

au({ "CmdLineLeave" }, {
    group = search,
    callback = function()
        vim.opt.smartcase = true
    end
})

au('BufReadPre', {
    group = large_files,
    callback = function()
        local max_filesize = 100 * 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
            vim.b.minihipatterns_disable = true
        end
    end
})
