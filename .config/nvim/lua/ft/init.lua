local api = vim.api

local extension_tbl = {
    ["lua"] = "lua",
    ["c"] = "c",
    ["cpp"] = "cpp",
    ["css"] = "css",
    ["diff"] = "diff",
    ["h"] = "c",
    ["py"] = "python",
    ["html"] = "html",
    ["txt"] = "text",
    ["http"] = "http",
    ["sh"] = "bash",
    ["zsh"] = "bash",
    ["toml"] = "conf",
    ["yaml"] = "yaml",
    ["json"] = "json",
    ["ini"] = "ini",
    ["tex"] = "latex",
    ["md"] = "markdown",
    ["conf"] = "conf",
    ["go"] = "go",
}

local function ft_detect()
    local file_ext = vim.fn.expand("%:e")
    local filetype = extension_tbl[file_ext] or "text"

    vim.bo.ft = filetype

    vim.defer_fn(function()
        pcall(api.nvim_command, "luafile ~/.config/nvim/lua/ft/" .. filetype .. "/init.lua")
    end, 100)
end

ft_detect()

api.nvim_create_autocmd("BufReadPost", {
    callback = ft_detect
})
