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

au({ "TermClose" }, {
    callback = function()
        vim.cmd.bdelete()
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

au('BufReadPre', {
    callback = function()
        local max_filesize = 100 * 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
            vim.b.minihipatterns_disable = true
        end
    end
})

au("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<M-o>", function()
            vim.lsp.buf.hover({ border = "single" })
        end, opts)
        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<space>ih",
            function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(opts))
            end, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set({ "n", "v" }, "<space>ca",
            function() vim.lsp.buf.code_action { only = { "quickfix" } } end, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = 1, float = false })
        end, opts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = -1, float = false })
        end, opts)

        vim.keymap.set("n", "=l", function()
            vim.diagnostic.setloclist({ open = false })
            local win = vim.api.nvim_get_current_win()
            local qf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
            local action = qf_winid > 0 and "lclose" or "silent! lopen"
            vim.cmd(action)
        end, { silent = true })

        vim.keymap.set("n", "=q", function()
            vim.diagnostic.setqflist({ open = false })
            local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
            local action = qf_winid > 0 and "cclose" or "copen"
            vim.cmd(action)
        end, { silent = true })

        vim.keymap.set("n", "=f", function()
            local win = vim.api.nvim_get_current_win()
            local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
            local lf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
            if qf_winid > 0 then
                vim.cmd("copen")
            elseif lf_winid > 0 then
                vim.cmd("lopen")
            else
                return
            end
        end)
        --
        local function update_list_if_visible()
            local loclist = vim.fn.getloclist(0, { winid = 0 })
            local qflist = vim.fn.getqflist({ winid = 0 })
            if loclist.winid ~= 0 then
                vim.diagnostic.setloclist({ open = false })
            end
            if qflist.winid ~= 0 then
                vim.diagnostic.setqflist({ open = false })
            end
        end

        au("DiagnosticChanged", {
            callback = update_list_if_visible,
        })

        for _, client in pairs(vim.lsp.get_clients()) do
            if client.name ~= "copilot" then
                vim.keymap.set("n", "<C-s>", function()
                    vim.lsp.buf.format()
                    vim.cmd("silent! write")
                end, opts)
            end
        end
    end,
})
