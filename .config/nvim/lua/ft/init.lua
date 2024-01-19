local extension_tbl = {
    ["toml"] = "toml",
    ["conf"] = "toml",
    ["typ"] = "typst",
    ["lua"] = "lua",
    ["c"] = "c",
    ["cpp"] = "cpp",
    ["cc"] = "cpp",
    ["h"] = "c",
    ["py"] = "python",
    ["html"] = "html",
    ["txt"] = "text",
    ["css"] = "css",
    ["rs"] = "rust",
    ["zig"] = "zig",
    ["ts"] = "typescript",
    ["js"] = "javascript",
    ["sh"] = "sh",
    ["zsh"] = "sh",
    ["go"] = "go",
}

local function ft_detect()
    local file_ext = vim.fn.expand("%:e")
    local filetype = extension_tbl[file_ext] or "text"

    vim.bo.ft = filetype

    -- vim.defer_fn(function()
    --     pcall(api.nvim_command, "luafile ~/.config/nvim/lua/ft/" .. filetype .. "/init.lua")
    -- end, 100)
end

ft_detect()

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = ft_detect
})
