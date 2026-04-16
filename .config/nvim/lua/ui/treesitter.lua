-- local ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "css", "go", "python", "bash",
--     "diff", "yaml", "xml", "markdown", "ini", "json", "html", "typst", "make", "toml", "javascript" }
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = vim.api.nvim_create_augroup("Treesitter", {}),
    callback = function(args)
        local buf = args.buf
        local filetype = args.match

        local language = vim.treesitter.language.get_lang(filetype) or filetype
        if not vim.treesitter.language.add(language) then
            return
        end

        local max_filesize = 256 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
            return
        end

        vim.treesitter.start(buf, language)
    end,
})

--treesitter
vim.keymap.set({ "n", "x", "o" }, "<Tab>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_parent(vim.v.count1)
    else
        vim.lsp.buf.selection_range(vim.v.count1)
    end
end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

vim.keymap.set({ "n", "x", "o" }, "<S-Tab>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_child(vim.v.count1)
    else
        vim.lsp.buf.selection_range(-vim.v.count1)
    end
end, { desc = "Select child treesitter node or inner incremental lsp selections" })
