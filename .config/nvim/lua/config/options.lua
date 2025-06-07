local options = {
    report        = 100,
    cmdheight     = 1,
    undofile      = true,
    undolevels    = 100,
    ignorecase    = true,
    lazyredraw    = true,
    omnifunc      = "syntaxcomplete#Complete",
    completeopt   = "longest,menuone",
    tabstop       = 4,
    shiftwidth    = 4,
    expandtab     = true,
    signcolumn    = "no",
    matchpairs    = "(:),{:},[:],<:>",
    cursorline    = true,
    list          = true,
    fillchars     = "eob: ,foldopen:┃,foldsep:┃",
    listchars     = "tab:  ",
    foldenable    = false,
    foldexpr      = "v:lua.vim.treesitter.foldexpr()",
    foldtext      = "",
    guicursor     = "",
    wildoptions   = "pum,fuzzy",
    splitright    = true,
    splitbelow    = true,
    pumheight     = math.floor(vim.o.lines * 0.33),
    shortmess     = "aIF",
    commentstring = "#%s",
    grepprg       = "rg --color=auto --vimgrep",
    grepformat    = "%f:%l:%c:%m",
    mouse         = "",
    wrap          = false,
    inccommand    = "split",
    cmdwinheight  = math.floor(vim.o.lines * 0.28),
}

local au = vim.api.nvim_create_autocmd
au({ "VimResized" },
    {
        callback = function()
            vim.api.nvim_set_option_value("cmdwinheight", math.floor(vim.o.lines * 0.28), {})
            vim.api.nvim_set_option_value("pumheight", math.floor(vim.o.lines * 0.33), {})
        end
    }
)

for key, val in pairs(options) do
    vim.api.nvim_set_option_value(key, val, {})
end

vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0
