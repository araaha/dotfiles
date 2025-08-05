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

return {
    s(
        {
            trig = "main",
            regTrig = false,
            snippetType = "snippet",
            hidden = false,
        }, fmta([[package main

func main() {
    <>
}]], ls.i(0))
    ),
    s(
        {
            trig = "for([%w_]+)",
            regTrig = true,
            snippetType = "autosnippet",
            wordTrig = true,
            hidden = true,
        }, fmta([[for <> := <>; <> << <>; <>++ {
    <>
}]], {
            d(1, function(_, snip)
                return sn(1, i(1, snip.captures[1]))
            end),
            i(2),
            rep(1),
            i(3),
            rep(1),
            i(4)
        })),
    s(
        {
            trig = "pfor",
            snippetType = "snippet",
            desc = "Snippet for a pure for loop",
            hidden = false
        }, fmta("for <> {\n\t<>\n}", {
            i(0), i(1)
        })
    ),
    s(
        {
            trig = "rng",
            snippetType = "autosnippet",
            desc = "Range",
            hidden = false
        }, fmta("for <>, <> := range <> {\n\t<>\n}", {
            i(1, "_"), i(2, "v"), i(3), i(4)
        })
    ),
    s(
        {
            trig = "tyi",
            snippetType = "autosnippet",
            hidden = false,
        }, fmta("type <> interface {\n\t<>\n}", {
            i(1), i(2)
        })
    ),
    s(
        {
            trig = "tys",
            snippetType = "autosnippet",
            hidden = true,
        }, fmta("type <> struct {\n\t<>\n}", {
            i(1), i(2)
        })
    ),
    s(
        {
            trig = "func",
            snippetType = "snippet",
            hidden = false,
        }, fmta("func <> {\n\t<>\n}", { i(1), i(2) })
    ),
    s(
        {
            trig = "switch",
            snippetType = "snippet",
            hidden = false,
        }, fmta("switch <> {\ncase <>:\n\t<>\n}", { i(1, "expression"), i(2, "condition"), i(3) })
    ),
    s(
        {
            trig = "map",
            snippetType = "snippet",
            hidden = false,
        }, fmta("map[<>]<>", { i(1, "type"), i(2, "type") })
    ),
    s(
        {
            trig = "ek",
            snippetType = "snippet",
            hidden = false,
        }, fmta("if <>, ok := <>[<>]; ok {\n\t<>\n}", {
            i(1, "val"), i(2, "map"), i(3, "key"), i(4)
        })
    ),
    s(
        {
            trig = "iferr",
            snippetType = "autosnippet",
            hidden = false,
        }, fmta("if err != nil {\n\t<>\n}", {
            i(1)
        })
    ),
}
