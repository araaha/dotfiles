vim.cmd([[
  syntax off
  filetype off
  filetype plugin indent off
]])
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

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    checker = { enabled = false },         -- automatically check for plugin updates
    change_detection = { notify = false }, -- automatically check for plugin updates
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "tarPlugin",
                "zipPlugin",
                "tohtml",
                "tutor",
                "man",
                "spellfile",
                "health",
                "editorconfig",
            },
        },
    },
})

vim.defer_fn(function()
    require("options")
    require("keymaps")
    require("autocmds")
    require("statusline")
    require("lsploc")
    vim.cmd([[
      syntax on
      filetype on
      filetype plugin indent on
    ]])
end, 0)
