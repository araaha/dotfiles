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


local main = s(
    {
        trig = 'main',
        regTrig = false,
        snippetType = 'snippet',
        hidden = false,
    }, fmta("package main \n\nfunc main() {\n\t<>\n}", ls.i(0)))
table.insert(snippets, main)

return snippets
