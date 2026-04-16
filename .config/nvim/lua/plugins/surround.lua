local functions = {
    ["lua"] = { "function() ", " end" }
}
return {
    "kylechui/nvim-surround",
    keys = {
        { "S", mode = "v" },
        "ys",
        "cs",
        "ds"
    },
    opts = {
        -- aliases = {
        --     ["a"] = ">",
        --     ["b"] = ")",
        --     ["B"] = "}",
        --     ["r"] = "]",
        --     ["q"] = { '"', "'", "`" },
        --     ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        -- },
        surrounds = {
            ["F"] = {
                add = function()
                    return functions[vim.bo.ft]
                end,
                -- delete=
            }
        }
    },
}
