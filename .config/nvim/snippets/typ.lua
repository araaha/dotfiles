local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local snippets = {}


local su = s(
    {
        trig = "su",
        regTrig = false,
        snippetType = "autosnippet",
        hidden = false,
    }, fmt([[sum_({})_({}) ]], {
        i(1, ""),
        i(2, ""),
    }))

table.insert(snippets, su)

return snippets
