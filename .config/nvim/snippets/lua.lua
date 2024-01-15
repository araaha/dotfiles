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

local plug = s(
    {
        trig = 'plug',
        regTrig = false,
        snippetType = 'autosnippet',
        hidden = true,
    }, fmt([[
    {{
        "{}",
        version = {},
        lazy    = {},
        event   = {},
        opts    = {{}},
        config  = function()
            require("{}").setup(opts)
        end,
    }},
]], {
        i(1, ""),
        i(2, "false"),
        i(3, "true"),
        i(4, "\"VeryLazy\""),
        i(5, ""),
    }))
table.insert(snippets, plug)


return snippets
