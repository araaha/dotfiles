local M = {}

local ensure_installed = {
    "c", "lua", "vim", "vimdoc", "cpp", "css", "go", "python", "bash",
    "diff", "yaml", "xml", "markdown", "markdown_inline", "ini", "json",
    "html", "typst", "make", "toml", "javascript",
}

-- Use nvim-treesitter only as an on-demand installer, not a startup plugin.
function M.install(force)
    local installer = vim.fn.stdpath("cache") .. "/treesitter-installer"
    if vim.fn.isdirectory(installer) == 0 then
        local result = vim.system({
            "git", "clone", "--depth", "1", "--branch", "main",
            "https://github.com/nvim-treesitter/nvim-treesitter", installer,
        }, { text = true }):wait()
        assert(result.code == 0, result.stderr)
    end
    vim.opt.runtimepath:prepend(installer)
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    return treesitter.install(ensure_installed, { force = force, summary = true })
end

return M
