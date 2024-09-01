require("nvim-surround").buffer_setup({
    surrounds = {
        ["F"] = {
            add = { "function() ", " end" },
            find = function()
                local ts_utils = require("nvim-treesitter.ts_utils")

                local root = ts_utils.get_node_at_cursor()
                while root and root:type() ~= "function_definition" do
                    root = root:parent()
                end
                if root then
                    local first_lnum, first_col, last_lnum, last_col = root:range()
                    return {
                        first_pos = { first_lnum + 1, first_col + 1 },
                        last_pos = { last_lnum + 1, last_col },
                    }
                end
            end,
            delete = "^(function%b())().-(end)()$",
        },
    },
})
