local opts = {
    modes = { insert = true, command = false, terminal = false },

    mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { cr = true } },
        -- ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },

        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\].", register = { cr = true } },
        -- [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

        ["\""] = { action = "closeopen", pair = "\"\"", neigh_pattern = "[^\\].", register = { cr = true } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^\\].", register = { cr = false } },
    },
}

return {
    "echasnovski/mini.pairs",
    version = false,
    keys    = {
        { "'",    mode = "i" },
        { "\"",   mode = "i" },
        { "{",    mode = "i" },
        { "}",    mode = "i" },
        { "(",    mode = "i" },
        { ")",    mode = "i" },
        { "[",    mode = "i" },
        { "]",    mode = "i" },
        { "<",    mode = "i" },
        { ">",    mode = "i" },
        { "<CR>", mode = "i" }
    },
    opts    = opts,
}
