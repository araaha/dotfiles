return {
    "echasnovski/mini.hipatterns",
    version = false,
    event   = "VeryLazy",
    config  = function()
        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
            highlighters = {
                -- Highlight standalone "FIXME", "HACK" , "TODO", "NOTE"
                hack      = { pattern = "HACK", group = "MiniHipatternsHack" },
                fixme     = { pattern = "FIXME", group = "MiniHipatternsFixme" },
                todo      = { pattern = "TODO", group = "MiniHipatternsTodo" },
                note      = { pattern = "NOTE", group = "MiniHipatternsNote" },

                hex_color = hipatterns.gen_highlighter.hex_color(),
                trailing  = {
                    pattern = function(buf_id)
                        if vim.bo[buf_id].filetype == "go" then return nil end
                        return "%f[%s]%s-$"
                    end,
                    group = "Todo"
                },

                rgb       = {
                    pattern = "rgb%(%s-%x+%s-,%s-%x+%s-,%s-%x+%s-%)",
                    group = function(_, match)
                        local pattern = "rgb%(%s-(%x+)%s-,%s-(%x+)%s-,%s-(%x+)%s-%)"
                        local r, g, b = match:match(pattern)
                        local bit = require("bit")
                        local red = bit.tohex(r, 2)
                        local blue = bit.tohex(g, 2)
                        local green = bit.tohex(b, 2)
                        local hex = "#" .. red .. blue .. green
                        return hipatterns.compute_hex_color_group(hex, "bg")
                    end
                },

            }
        })
    end
}
