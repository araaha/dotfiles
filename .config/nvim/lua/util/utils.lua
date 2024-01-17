local M = {}

M.load_configs = function()
    for _, file in ipairs(M.get_config_modules()) do
        require("config." .. file)
    end
    require("config.lazy")
end

M.get_config_modules = function()
    local exclude_map = {
        "lazy",
        "init",
    }
    local files = {}
    for _, file in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/lua/config/*.lua", true, true)) do
        table.insert(files, vim.fn.fnamemodify(file, ":t:r"))
    end
    files = vim.tbl_filter(function(file)
        for _, pattern in ipairs(exclude_map) do
            if file:match(pattern) then
                return false
            end
        end
        return true
    end, files)
    return files
end


M.au_loclist = "LspLocList"

function M.update_loclist_if_visible()
    local loclist = vim.fn.getloclist(0, { winid = 0 })
    if loclist.winid ~= 0 then
        vim.diagnostic.setloclist()
    end
end

function M.setup_loclist_update()
    vim.api.nvim_create_augroup(M.au_loclist, { clear = true })
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = M.au_loclist,
        callback = M.update_loclist_if_visible,
    })
end

M.setup_loclist_update()

return M
