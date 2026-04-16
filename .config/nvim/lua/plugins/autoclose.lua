return {
    "m4xshen/autoclose.nvim",
    keys = {
        { "{",    mode = "i" },
        { "}",    mode = "i" },
        { "(",    mode = "i" },
        { ")",    mode = "i" },
        { "[",    mode = "i" },
        { "]",    mode = "i" },
        { "\"",   mode = "i" },
        { "<CR>", mode = "i" },
        { ":",    mode = "n" },
    },
    opts = {
        keys = {
            ["("] = { escape = false, close = true, pair = "()" },
            ["["] = { escape = false, close = true, pair = "[]" },
            ["{"] = { escape = false, close = true, pair = "{}" },

            [">"] = { escape = true, close = false, pair = "<>" },
            [")"] = { escape = true, close = false, pair = "()" },
            ["]"] = { escape = true, close = false, pair = "[]" },
            ["}"] = { escape = true, close = false, pair = "{}" },

            ['"'] = { escape = true, close = true, pair = '""' },
            ["'"] = { escape = true, close = true, pair = "''" },
            ["`"] = { escape = true, close = true, pair = "``" },
        },
        options = {
            disabled_filetypes = { "text" },
            disable_when_touch = false,
            touch_regex = "[%w(%[{]",
            pair_spaces = true,
            auto_indent = true,
            disable_command_mode = false,
        },
    }
}
