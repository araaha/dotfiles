return {
    "backdround/neowords.nvim",
    version = false,
    keys    = {
        { "w", mode = { "n", "v", "o" } },
        { "e", mode = { "n", "v", "o" } },
        { "b", mode = { "n", "v", "o" } },
        { "ge", mode = { "n", "v", "o" } },
    },
    config  = function()
        local neowords = require("neowords")
        local p = neowords.pattern_presets
        local hops = neowords.get_word_hops(
            p.snake_case,
            p.camel_case,
            p.upper_case,
            p.number,
            p.hex_color,
            "\\v\\=+"
        )

        vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
        vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
        vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
        vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
    end,
}
