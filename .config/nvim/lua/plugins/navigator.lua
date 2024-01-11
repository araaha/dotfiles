return {
    'numToStr/Navigator.nvim',
    version = false,
    keys    = {
        "<A-h>", "<A-l>", "<A-k>", "<A-j>"
    },
    config  = function()
        require('Navigator').setup()
        vim.keymap.set({ 'i', 'n', 't' }, '<A-h>', '<CMD>NavigatorLeft<CR>')
        vim.keymap.set({ 'i', 'n', 't' }, '<A-l>', '<CMD>NavigatorRight<CR>')
        vim.keymap.set({ 'i', 'n', 't' }, '<A-k>', '<CMD>NavigatorUp<CR>')
        vim.keymap.set({ 'i', 'n', 't' }, '<A-j>', '<CMD>NavigatorDown<CR>')
    end
}
