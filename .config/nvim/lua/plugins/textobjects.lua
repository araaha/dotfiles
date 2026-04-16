return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    keys = {
        {
            "af",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@function.outer", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "if",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@function.inner", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "ac",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@call.outer", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "ic",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@call.inner", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "ai",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@conditional.outer", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "ii",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@conditional.inner", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "ao",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@block.outer", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "io",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@block.inner", "textobjects")
            end,
            mode = { "x", "o" },
        },
        {
            "as",
            function()
                require("nvim-treesitter-textobjects.select")
                    .select_textobject("@scope", "locals")
            end,
            mode = { "x", "o" },
        },
        {
            "dof",
            function()
                local select = require("nvim-treesitter-textobjects.select")
                select.select_textobject("@function.inner", "textobjects")
                vim.cmd([[normal! "ay"_d]])
                select.select_textobject("@function.outer", "textobjects")
                vim.cmd([[normal! "aP]])
            end,
            mode = "n",
        },
        {
            "]m",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_next_start("@function.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "]]",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_next_start("@class.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "]M",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_next_end("@function.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "][",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_next_end("@class.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "[m",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_previous_start("@function.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "[[",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_previous_start("@class.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "[M",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_previous_end("@function.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
        {
            "[]",
            function()
                require("nvim-treesitter-textobjects.move")
                    .goto_previous_end("@class.outer", "textobjects")
            end,
            mode = { "n", "x", "o" },
        },
    },

    opts = function()
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
            return
        end
        return {
            select = {
                lookahead = true,
                selection_modes = {
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "<c-v>",
                },
            },
            move = {
                set_jumps = true,
            },
        }
    end
}
