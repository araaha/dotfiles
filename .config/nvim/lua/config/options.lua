local o                   = vim.opt
local g                   = vim.g

o.report                  = 100
o.cmdheight               = 1
o.hlsearch                = true
o.undofile                = true
o.updatetime              = 1000
o.ignorecase              = true
o.lazyredraw              = true
o.omnifunc                = "syntaxcomplete#Complete"
o.completeopt             = "longest,menuone"
o.tabstop                 = 4
o.shiftwidth              = 4
o.expandtab               = true
o.signcolumn              = "no"
o.matchpairs              = "(:),{:},[:],<:>"
o.cursorline              = true
o.listchars               = {
    eol = '↵',
    trail = '·',
    nbsp = '.',
    multispace = '···⬝',
    leadmultispace = '│ '
}
o.list                    = false
o.fillchars               = 'eob: '
o.foldexpr                = "v:lua.vim.treesitter.foldexpr()"
o.foldtext                = "v:lua.vim.treesitter.foldtext()"
o.guicursor               = ""
o.wildoptions             = "pum,fuzzy"
o.splitright              = true
o.splitbelow              = true
o.pumheight               = 12
o.shortmess               = "aIF"

g.loaded_python3_provider = 0
g.loaded_node_provider    = 0
g.loaded_ruby_provider    = 0
g.loaded_perl_provider    = 0

vim.diagnostic.config({
    virtual_text = true, -- Turn off inline diagnostics
})
