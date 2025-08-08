return {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    opts  = {
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = function()
                local max_filesize = 256 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
                return ok and stats and stats.size > max_filesize
            end,
        },
        incremental_selection = {
            enable = true,
            disable = function() -- Disable in large C++ buffers
                local max_filesize = 512 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
                return ok and stats and stats.size > max_filesize
            end,
            keymaps = {
                node_incremental = "<TAB>",
                node_decremental = "<S-TAB>",
            },
        },
        ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "css", "go", "python", "bash",
            "diff", "yaml", "xml", "markdown", "ini", "json", "html", "typst", "make", "toml", "javascript" },
    },
    main  = "nvim-treesitter.configs"
}
