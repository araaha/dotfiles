return {
    "backdround/neowords.nvim",
    version = false,
    keys    = { "w", "e", "b" },
    config  = function()
        local neowords = require("neowords")
        local p = neowords.pattern_presets
        local hops = neowords.get_word_hops(
            p.snake_case,
            p.camel_case,
            p.upper_case,
            p.number,
            p.hex_color
        )

        vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
        vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
        vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
        vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
    end,
}
