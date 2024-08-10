local opts = {
    textobjects = {
        select = {
            enable = true,
            disable = function()                -- Disable in large C++ buffers
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
                return ok and stats.size > max_filesize
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
    opts    = opts,
    keys    = {
        "]",
        "[",
        { "af",  "<cmd>TSTextobjectSelect @function.outer<cr>",                                                        mode = { "v", "o" } },
        { "if",  "<cmd>TSTextobjectSelect @function.inner<cr>",                                                        mode = { "v", "o" } },
        { "ai",  "<cmd>TSTextobjectSelect @conditional.outer<cr>",                                                     mode = { "v", "o" } },
        { "ii",  "<cmd>TSTextobjectSelect @conditional.inner<cr>",                                                     mode = { "v", "o" } },
        { "ao",  "<cmd>TSTextobjectSelect @block.outer<cr>",                                                           mode = { "v", "o" } },
        { "io",  "<cmd>TSTextobjectSelect @block.inner<cr>",                                                           mode = { "v", "o" } },
        { "ac",  "<cmd>TSTextobjectSelect @call.outer<cr>",                                                            mode = { "v", "o" } },
        { "ic",  "<cmd>TSTextobjectSelect @call.inner<cr>",                                                            mode = { "v", "o" } },
        { "as",  "<cmd>TSTextobjectSelect { query = @scope, query_group = \"locals\" }<cr>",                           mode = { "v", "o" } },
        { "dof", "<cmd>TSTextobjectSelect @function.inner<cr>\"ay\"_d<cmd>TSTextobjectSelect @function.outer<cr>\"aP", mode = { "n" } },
    },
    config  = function()
        -- fix
        require("nvim-treesitter.configs").setup(opts)
    end
}
