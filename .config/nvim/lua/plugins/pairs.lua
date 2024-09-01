return {
    "echasnovski/mini.pairs",
    keys = {
        { "{",     mode = "i" },
        { "}",     mode = "i" },
        { "(",     mode = "i" },
        { ")",     mode = "i" },
        { "[",     mode = "i" },
        { "]",     mode = "i" },
        { "<CR>",  mode = "i" },
        { "<C-w>", "v:lua.MiniPairs.bs('\23')", mode = "i", expr = true, replace_keycodes = false }
    },
    opts = {
        modes = { insert = true, command = false, terminal = false },

        mappings = {
            ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
            ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
            ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { cr = true } },

            [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
            ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
            ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\].", register = { cr = true } },
        },
    }
}
