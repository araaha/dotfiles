vim.lsp.enable({
    "gopls",
    "bashls",
    "ruff",
    "pyright",
    "lua_ls",
    "clangd"
}, true)

vim.diagnostic.config({
    virtual_text = true,
    underline = false,
    signs = false
})
