local opts = {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = function(lang, bufnr) -- Disable in large C++ buffers
            return lang == "cpp" and vim.api.nvim_buf_line_count(bufnr) > 50000
        end,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
        },
    },
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "cpp", "latex", "css", "go", "python", "bash",
        "diff", "yaml", "markdown", "ini", "json" },
}

return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    lazy    = true,
    event   = "VeryLazy",
    config  = function()
        require("nvim-treesitter.configs").setup(opts)
        vim.treesitter.language.register("bash", "zsh")
    end,
}
