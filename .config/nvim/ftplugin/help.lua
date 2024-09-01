vim.bo.buflisted = true
vim.cmd("resize " .. vim.o.lines * 0.45)

vim.api.nvim_create_autocmd({ "VimResized" },
    {
        callback = function()
            if vim.bo.buftype == "help" then
                vim.cmd("resize " .. vim.o.lines * 0.45)
            end
        end
    }
)
