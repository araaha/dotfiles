local opts = {
    undercurl = false,
    underline = false,
    bold = true,
    italic = {
        strings = false,
        comments = true,
        operators = false,
        folds = false,
        emphasis = false,
    },
    strikethrough = false,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = false, -- invert background for search, diffs, statuslines and errors
    palette_overrides = {
        bright_green = "#9DC365",
        neutral_green = "#9DC365",
        dark2 = "#7C6F64",
        dark0 = "#242424",

    },
    overrides = {
        Search = { bg = "#83A598", fg = "#242424" },
        IncSearch = { bg = "#D8A657", fg = "#242424" },
        Visual = { bg = "#3F3F3F", fg = "None" },

        Pmenu = { fg = "None", bg = "None" },
        PmenuSel = { fg = "#E6DBAF", bg = "#7C6F64" },
        PmenuSbar = { fg = "None", bg = "None" },
        PmenuThumb = { fg = "None", bg = "None" },

        ["@constant.bash"] = { link = "GruvboxBlue" },
        ["@function.builtin.bash"] = { link = "GruvboxRed" },
        ["@namespace"] = { link = "GruvboxRed" },
        ["@variable"] = { link = "GruvboxBlue" },
        ["@tag.xml"] = { link = "GruvboxBlue" },
        ["@tag.delimiter.xml"] = { link = "GruvboxBlue" },
        ["@module"] = { link = "GruvboxBlue" },

        zshVariableDef = { link = "GruvboxBlue" },

        TermCursor = { bg = "#9cd365", fg = "None" },
        StatusLine = { bg = "#242424", fg = "None" },
        StatusLineNC = { bg = "#242424", fg = "#E6DBAF" },

        QuickFixLine = { bg = "None", fg = "None" },
        FloatBorder = { link = "GruvboxBlue" },
        NonText = { link = "GruvboxBg4" },
        SpecialKey = { link = "GruvboxBg4" },
        SpecialChar = { link = "GruvboxRed" },

        FzfLuaBufLineNr = { link = "GruvboxBlue" },

        NvimSurroundHighlight = { bg = "#FE8019", fg = "#242424" },

        HopNextKey = { fg = "#242424", bg = "#83A598" },
        HopNextKey1 = { fg = "#242424", bg = "#83A598" },
        HopNextKey2 = { fg = "#242424", bg = "#D8A657" },

        BqfSign = { fg = "#9DC365", bg = "None" },
        IndentLine = { fg = "#FABD2F" },
    },
    dim_inactive = false,
    transparent_mode = true,
}

return {
    "ellisonleao/gruvbox.nvim",
    version = false,
    lazy    = true,
    event   = "VeryLazy",
    opts    = opts,
    config  = function()
        require("gruvbox").setup(opts)
        vim.cmd("colorscheme gruvbox")
    end,
}
