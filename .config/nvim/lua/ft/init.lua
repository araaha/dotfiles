-- local extension_tbl = {
--     ["toml"] = "toml",
--     ["conf"] = "toml",
--     ["typ"] = "typst",
--     ["ini"] = "ini",
--     ["json"] = "json",
--     ["md"] = "markdown",
--     ["yaml"] = "yaml",
--     ["diff"] = "diff",
--     ["tex"] = "latex",
--     ["vimdoc"] = "vimdoc",
--     ["vim"] = "vim",
--     ["lua"] = "lua",
--     ["c"] = "c",
--     ["cpp"] = "cpp",
--     ["cc"] = "cpp",
--     ["h"] = "c",
--     ["py"] = "python",
--     ["html"] = "html",
--     ["txt"] = "text",
--     ["css"] = "css",
--     ["scss"] = "css",
--     ["ts"] = "typescript",
--     ["js"] = "javascript",
--     ["sh"] = "sh",
--     ["zsh"] = "sh",
--     ["go"] = "go",
--
-- }
--
-- local function ft_detect()
--     local file_ext = vim.fn.expand("%:e")
--     local filetype = extension_tbl[file_ext] or "text"
--
--     if vim.bo.buftype == "quickfix" then
--         vim.bo.ft = "qf"
--     else
--         vim.bo.ft = filetype
--     end
-- end
--
-- ft_detect()
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
--     callback = ft_detect
-- })
--
-- vim.defer_fn(function()
--     ft_detect()
-- end, 0)

vim.filetype.add({
    extension = {
        conf = 'toml'
    }
})

vim.filetype.add({
    extension = {
        typ = 'typst'
    }
})
