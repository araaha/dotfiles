local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

if pcall(vim.cmd.packadd, "nvim.undotree") then
    local ok, undotree = pcall(require, "undotree")
    if ok then
        vim.keymap.set("n", "<Leader>u", undotree.open)
    end
end

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    checker = { enabled = false },
    change_detection = {
        enabled = false
    },
    ui = {
        border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
    },
    rocks = {
        enabled = false
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchparen",
                "matchit",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "filetype",
                "health",
                "man",
                "shada",
                "nvim",
                "spellfile",
                "rplugin",
                "zipPlugin",
                "editorconfig",
                "osc52",
            },
        },
    },
})
