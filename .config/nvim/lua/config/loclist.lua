local M = {}

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
