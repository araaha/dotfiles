local opts = {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = function(lang, bufnr) -- Disable in large C++ buffers
            return lang == "cpp" and vim.api.nvim_buf_line_count(bufnr) > 11000
        end,
    },
    incremental_selection = {
        enable = true,
        disable = function(lang, bufnr) -- Disable in large C++ buffers
            return lang == "cpp" and vim.api.nvim_buf_line_count(bufnr) > 11000
        end,
        keymaps = {
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
        },
    },
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "cpp", "latex", "css", "go", "python", "bash",
        "diff", "yaml", "markdown", "ini", "json", "html" },
}

return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event   = "VeryLazy",
    config  = function()
        require("nvim-treesitter.configs").setup(opts)
    end,
}
