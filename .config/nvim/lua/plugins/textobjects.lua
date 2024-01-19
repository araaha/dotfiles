local opts = {
    textobjects = {
        select = {
            enable = true,
            disable = function(lang, bufnr) -- Disable in large C++ buffers
                return lang == "cpp" and vim.api.nvim_buf_line_count(bufnr) > 11000
            end,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@call.outer",
                ["ic"] = { query = "@call.inner", desc = "Select inner part of a function call" },
                ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            }
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
                ["]d"] = "@conditional.outer",
            },
            goto_previous = {
                ["[d"] = "@conditional.outer",
            }
        },
    },
}

return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    version = false,
    keys    = {
        "]",
        "[",
        { "af", "<cmd>TStextobjectSelect @function.outer<cr>",                            mode = "v" },
        { "if", "<cmd>TStextobjectSelect @function.inner<cr>",                            mode = "v" },
        { "ac", "<cmd>TStextobjectSelect @call.outer<cr>",                                mode = "v" },
        { "ic", "<cmd>TStextobjectSelect { query = @call.inner }<cr>",                    mode = "v" },
        { "as", "<cmd>TStextobjectSelect { query = @scope, query_group = 'locals' }<cr>", mode = "v" },
    },
    lazy    = true,
    config  = function()
        require("nvim-treesitter.configs").setup(opts)
    end,
}
