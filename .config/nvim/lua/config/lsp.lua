vim.lsp.enable({
    "gopls",
    "bashls",
    "ruff",
    "ty",
    "lua_ls",
    "jdtls",
    "clangd"
}, true)

vim.diagnostic.config({
    virtual_text = true,
    underline = false,
    signs = false
})

local au = vim.api.nvim_create_autocmd
au("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "go", function()
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
        -- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
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
        vim.keymap.set("n", "<C-s>", function()
            local clients = vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" })
            if #clients > 0 then
                vim.lsp.buf.format({ bufnr = ev.buf })
            end
            vim.cmd("silent! write")
        end, opts)

    end,
})

local group = vim.api.nvim_create_augroup("UserLspLists", { clear = true })
au("DiagnosticChanged", {
    group = group,
    callback = function()
        -- Location lists belong to windows; update all visible lists.
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.fn.getloclist(win, { winid = 0 }).winid ~= 0 then
                vim.api.nvim_win_call(win, function()
                    vim.diagnostic.setloclist({ open = false })
                end)
            end
        end
        if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
            vim.diagnostic.setqflist({ open = false })
        end
    end,
})
au("FileType", {
    group = group,
    pattern = "qf",
    callback = function(ev) vim.bo[ev.buf].buflisted = false end,
})
