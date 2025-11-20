local ls = require("luasnip")
local s = ls.s
local i = ls.i
-- local t = ls.t

-- local d = ls.dynamic_node
-- local c = ls.choice_node
-- local f = ls.function_node
-- local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
-- local rep = require("luasnip.extras").rep

return {
    s(
        {
            trig = "plug",
            snippetType = "snippet",
            regTrig = false,
            hidden = false,
        }, fmta([[
    return {
        "<>",
        opts    = {<>},
    }
]], {
            i(1),
            i(2),
        })
    ),
    s(
        {
            trig = "snip",
            regTrig = false,
            snippetType = "snippet",
            hidden = false,
        }, fmta([[
        s(
            {
                trig = "<>",
                snippetType = "<>",
                hidden = <>,
            }, fmta("<>", {
                <>
            })
        ),]], {
            i(1),
            i(2),
            i(3),
            i(4),
            i(5)
        })
    ),
}
