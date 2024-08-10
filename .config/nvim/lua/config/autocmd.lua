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

au({ "BufReadPost" }, {
    callback = remember,
})

au({ "CursorMoved" }, {
    callback = function()
        vim.cmd("norm! zz")
    end
})

au({ "BufEnter" }, {
    callback = function()
        if vim.bo.filetype == "help" then
            vim.cmd.only()
            vim.bo.buflisted = true
            vim.defer_fn(function()
                vim.cmd("norm! zz")
            end, 20)
        end
    end,
})

au({ "Filetype" }, {
    pattern = "qf",
    callback = function()
        vim.opt_local.wrap = true
    end
})

au({ "TermOpen" }, {
    callback = function()
        vim.cmd("startinsert")
    end
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
