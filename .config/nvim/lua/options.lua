vim.opt.hlsearch              = true
vim.opt.undofile              = true
vim.opt.updatetime            = 1000
vim.opt.ignorecase            = true
vim.opt.lazyredraw            = true
vim.opt.omnifunc              = "syntaxcomplete#Complete"
vim.opt.completeopt           = "longest,menuone"
vim.opt.tabstop               = 4
vim.opt.shiftwidth            = 4
vim.opt.expandtab             = true
vim.opt.signcolumn            = "no"
vim.opt.cursorline            = true
vim.opt.listchars             = {
    eol = '↵',
    trail = '·',
    nbsp = '.',
    multispace = '···⬝',
    leadmultispace = '│ '
}
vim.opt.list                  = false
vim.opt.syntax                = "off"
vim.opt.fillchars             = 'eob: '
vim.opt.foldexpr              = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext              = "v:lua.vim.treesitter.foldtext()"
vim.opt.guicursor             = ""
vim.opt.wildoptions           = "pum,fuzzy"
vim.opt.splitright            = true
vim.opt.splitbelow            = true
vim.opt.pumheight             = 12

vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0

vim.diagnostic.config({
    virtual_text = true, -- Turn off inline diagnostics
})
