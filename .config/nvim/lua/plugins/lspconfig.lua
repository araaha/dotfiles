return {
    "neovim/nvim-lspconfig",
    version = false,
    event   = { "VeryLazy" },
    config  = function()
        local lspconfig = require("lspconfig")
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
            { border = 'single' })
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<space>ca',
                    function() vim.lsp.buf.code_action { only = { "quickfix" } } end, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

                vim.keymap.set('n', '<C-s>', function()
                    if vim.bo.filetype == "sh" then
                        vim.cmd('silent w')
                    else
                        vim.lsp.buf.format()
                        vim.cmd('silent w')
                    end
                end, opts)

                vim.diagnostic.config({
                    virtual_text = true,
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
            cmd = { "gopls" },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
            }
        })
        lspconfig.pyright.setup({
        })
        lspconfig.lua_ls.setup({
            on_init = function(client)
                local path = client.workspace_folders[1].name
                if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                    client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                        Lua = {
                            runtime = {
                                -- Tell the language server which version of Lua you're using
                                -- (most likely LuaJIT in the case of Neovim)
                                version = 'LuaJIT'
                            },
                            -- Make the server aware of Neovim runtime files
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME
                                    -- "${3rd}/luv/library"
                                    -- "${3rd}/busted/library",
                                }
                                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                                -- library = vim.api.nvim_get_runtime_file("", true)
                            }
                        }
                    })
                    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                end
                return true
            end
        })
        lspconfig.bashls.setup({})

        vim.api.nvim_create_autocmd('DiagnosticChanged', {
            callback = function()
                vim.diagnostic.setloclist({ open = false })
            end
        })

        vim.cmd("LspStart")
        vim.api.nvim_create_autocmd("BufReadPost", { command = "LspStart" })
    end,
}
