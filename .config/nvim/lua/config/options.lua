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
    fillchars     = "eob: ",
    foldenable    = false,
    foldmethod    = "expr",
    foldexpr      = "v:lua.vim.treesitter.foldexpr()",
    foldtext      = "",
    guicursor     = "",
    wildoptions   = "pum,fuzzy",
    splitright    = true,
    splitbelow    = true,
    pumheight     = 12,
    shortmess     = "aIF",
    commentstring = "#%s",
    grepprg       = "rg --color=auto --vimgrep",
    grepformat    = "%f:%l:%c:%m",
    mouse         = ""
}

for key, val in pairs(options) do
    vim.api.nvim_set_option_value(key, val, {})
end

vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0

vim.opt.listchars             = {
    tab = "··",
}

vim.defer_fn(function()
    vim.opt.formatoptions:remove({ "o", "r" })
end, 20)
