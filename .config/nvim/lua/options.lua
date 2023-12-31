vim.o.hlsearch                = true
vim.o.undofile                = true
vim.o.updatetime              = 1000
vim.o.ignorecase              = true
vim.o.lazyredraw              = true
vim.o.omnifunc                = "syntaxcomplete#Complete"
vim.o.completeopt             = "longest,menuone"
vim.o.tabstop                 = 4
vim.o.shiftwidth              = 4
vim.o.expandtab               = true
vim.o.signcolumn              = "no"
vim.o.matchpairs              = "(:),{:},[:],<:>"
vim.o.cursorline              = true
vim.opt.listchars             = {
    eol = '↵',
    trail = '·',
    nbsp = '.',
    multispace = '···⬝',
    leadmultispace = '│ '
}
vim.o.list                    = false
vim.o.fillchars               = 'eob: '
vim.o.foldexpr                = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext                = "v:lua.vim.treesitter.foldtext()"
vim.o.guicursor               = ""
vim.o.wildoptions             = "pum,fuzzy"
vim.o.splitright              = true
vim.o.splitbelow              = true
vim.o.pumheight               = 12
vim.o.shortmess               = "I"

vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0

vim.diagnostic.config({
    virtual_text = true, -- Turn off inline diagnostics
})
