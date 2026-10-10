local M = {}

function M.open()
    local tmp = vim.fn.tempname()

    vim.cmd.vsplit()
    vim.cmd.enew()

    vim.fn.jobstart({ "yazi", "--chooser-file", tmp }, {
        term = true,
        on_exit = function()
            vim.schedule(function()
                local f = io.open(tmp, "r")
                if f then
                    local file = f:read("*l")
                    f:close()
                    os.remove(tmp)

                    if file and file ~= "" then
                        vim.cmd("vsplit " .. vim.fn.fnameescape(file))
                    end
                end
            end)
        end,
    })

    vim.cmd.startinsert()
end

return M
