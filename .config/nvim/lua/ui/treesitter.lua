vim.api.nvim_create_autocmd({ "FileType" }, {
    group = vim.api.nvim_create_augroup("Treesitter", { clear = true }),
    callback = function(args)
        local buf = args.buf
        local filetype = args.match

        -- The zsh ftplugin registers its Bash alias after the first screen.
        local language = filetype == "zsh" and "bash" or vim.treesitter.language.get_lang(filetype) or filetype
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
