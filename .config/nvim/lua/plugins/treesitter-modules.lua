return {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Tab>",
                node_incremental = "<Tab>",
                -- scope_incremental = "<A-O>",
                node_decremental = "<S-Tab>",
            },
        },
    },
}
