return {
    "gbprod/substitute.nvim",
    keys = {
        {
            "s",
            function() require("substitute").operator() end,
            mode = "n",
        },
        {
            "ss",
            function() require("substitute").line() end,
            mode = "n",
        },
        {
            "S",
            function() require("substitute").eol() end,
            mode = "n",
        },
        {
            "s",
            function() require("substitute").visual() end,
            mode = "x",
        },
        {
            "<Leader>s",
            function() require("substitute.range").operator() end,
            mode = "n",
        },
        {
            "<Leader>s",
            function() require("substitute.range").visual() end,
            mode = "x",
        },
        {
            "<Leader>ss",
            function() require("substitute.range").word() end,
            mode = "n",
        },
        {
            "sx",
            function() require("substitute.exchange").operator() end,
            mode = "n",
        },
        {
            "sxx",
            function() require("substitute.exchange").line() end,
            mode = "n",
        },
        {
            "X",
            function() require("substitute.exchange").visual() end,
            mode = "x",
        },
        {
            "sxc",
            function() require("substitute.exchange").cancel() end,
            mode = "n"
        }
    },
    opts = {}
}
