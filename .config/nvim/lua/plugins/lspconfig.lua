return {
    "neovim/nvim-lspconfig",
    version = false,
    event   = { "VeryLazy" },
    config  = function()
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
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
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
                vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set({ "n", "v" }, "<space>ca",
                    function() vim.lsp.buf.code_action { only = { "quickfix" } } end, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                vim.keymap.set("n", "<C-s>", function()
                    if vim.bo.filetype == "sh" or vim.bo.filetype == "" then
                        vim.cmd("silent w")
                    else
                        vim.lsp.buf.format()
                        vim.cmd("silent w")
                    end
                end, opts)

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
                            snippetSupport = false
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
                    -- Using Ruff's import organizer
                    disableOrganizeImports = true,
                },
                python = {
                    analysis = {
                        -- Ignore all files for analysis to exclusively use Ruff for linting
                        ignore = { '*' },
                    },
                },
            },
        })
        lspconfig.ruff.setup({
        })
        -- lspconfig.ruff_lsp.setup({
        -- })
        lspconfig.lua_ls.setup({
            on_init = function(client)
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT'
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            -- Depending on the usage, you might want to add additional paths here.
                            "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                        }
                        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                        -- library = vim.api.nvim_get_runtime_file("", true)
                    }
                })
            end,
            settings = {
                Lua = {
                    hint = { enable = true }
                }
            }
        })
        lspconfig.bashls.setup({})

        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            callback = function()
                vim.diagnostic.setloclist({ open = false })
                vim.diagnostic.setqflist({ open = false })
            end
        })

        lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config,
            { on_attach = function(client) client.server_capabilities.semanticTokensProvider = nil end })

        vim.cmd("LspStart")
        vim.api.nvim_create_autocmd("BufReadPost", { command = "LspStart" })
    end,
}
