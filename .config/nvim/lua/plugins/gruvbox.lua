local opts = {
    undercurl = false,
    underline = false,
    bold = false,
    italic = {
        strings = false,
        comments = true,
        operators = false,
        folds = false,
    },
    strikethrough = false,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = false, -- invert background for search, diffs, statuslines and errors
    palette_overrides = {
        bright_green = "#9dc365",
        neutral_green = "#9dc365",
        dark2 = "#7c6f64"
    },
    overrides = {
        Search = { bg = '#7DAEA3', fg = "#242424" },
        IncSearch = { bg = '#D8A657', fg = "#242424" },
        Visual = { bg = '#3f3f3f', fg = 'None' },
        ["@namespace"] = { fg = '#fb4934' },
        ["@variable"] = { fg = '#7DAEA3' },
        Pmenu = { fg = "None", bg = "None" },
        PmenuSel = { fg = "#e6dbaf", bg = "#7c6f64" },
        PmenuSbar = { fg = "None", bg = "None" },
        PmenuThumb = { fg = "None", bg = "None" },
        ["@constant.bash"] = { fg = "#7DAEA3" },
        ["@function.builtin.bash"] = { fg = "#fb4934" },
        StatusLine = { bg = "#242424", fg = "None" },
        StatusLineNC = { bg = "#242424", fg = "#e6dbaf" },
        QuickFixLine = { bg = "#242424", fg = "None" },
        FloatBorder = { fg = "#87afaf" },
        FzfLuaBufLineNr = { fg = "#87afaf" },
        SpecialKey = { fg = "#7c6f64" },
        NonText = { fg = "#7c6f64" },
        SpecialChar = { fg = "#fb4934" },
        NvimSurroundHighlight = { bg = "#fe8019", fg = "#242424" },
        HopNextKey = { fg = "#242424", bg = "#7daea3" },
        HopNextKey1 = { fg = "#242424", bg = "#7daea3" },
        HopNextKey2 = { fg = "#242424", bg = "#D8A657" }
    },
    dim_inactive = false,
    transparent_mode = true,
}

return {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    event = "VeryLazy",
    opts = opts,
    config = function()
        require("gruvbox").setup(opts)
        vim.cmd.colorscheme('gruvbox')
    end
}
