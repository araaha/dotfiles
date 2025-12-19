local ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "css", "go", "python", "bash",
    "diff", "yaml", "xml", "markdown", "ini", "json", "html", "typst", "make", "toml", "javascript" }
return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        require('nvim-treesitter').install(ensure_installed)

        vim.api.nvim_create_autocmd({ "FileType" }, {
            group = vim.api.nvim_create_augroup("treesitter.setup", {}),
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
    end,
}
