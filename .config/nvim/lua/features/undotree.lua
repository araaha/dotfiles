local M = {}

function M.load()
    if not vim.g.loaded_undotree_plugin then
        vim.cmd.packadd("nvim.undotree")
    end
end

function M.open()
    M.load()
    require("undotree").open()
end

return M
