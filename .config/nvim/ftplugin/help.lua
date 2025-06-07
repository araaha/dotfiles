vim.bo.buflisted = true

if vim.v.vim_did_enter == 1 then
    vim.cmd("resize " .. math.floor(vim.o.lines * 0.45))
end

vim.api.nvim_create_autocmd({ "VimResized" },
    {
        callback = function()
            if vim.bo.buftype == "help" then
                vim.cmd("resize " .. vim.o.lines * 0.45)
            end
        end
    }
)
