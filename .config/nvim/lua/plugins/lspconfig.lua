return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        local lspconfig = require("lspconfig")
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
            { border = "single" })
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "<M-o>", vim.lsp.buf.hover, opts)
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
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

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

                vim.api.nvim_create_autocmd("DiagnosticChanged", {
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

                vim.diagnostic.config({
                    virtual_text = true,
                    underline = false,
                })
            end,
        })
        lspconfig.gopls.setup({
            capabilities = {
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = true
                        },
                    },
                },
            },
            settings = {
                gopls = {
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    }
                },
            },
            cmd = { "gopls" },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
            }
        })
        lspconfig.pyright.setup({
            settings = {
                pyright = {
                    disableOrganizeImports = true,
                    disableLanguageServices = false,
                },
                python = {
                    analysis = {
                        ignore = { '*' },
                        autoImportCompletions = true
                    },
                },
            },
        })
        lspconfig.ruff.setup({})
        lspconfig.lua_ls.setup({
            on_init = function(client)
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library"
                        }
                    }
                })
            end,
            settings = {
                Lua = {
                    hint = { enable = true },
                    completion = {
                        callSnippet = "Replace"
                    }
                }
            }
        })
        lspconfig.bashls.setup({ filetypes = { "sh", "zsh" } })

        vim.cmd("LspStart")
    end,
}
