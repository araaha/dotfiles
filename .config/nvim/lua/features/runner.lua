local M = {}
local runners = {
    go = "go run",
    python = "python",
}

function M.run()
    local ft = vim.bo.filetype
    local cmd = runners[ft]
    if not cmd then
        print("No runner for filetype: " .. ft)
        return
    end

    local file = vim.fn.shellescape(vim.fn.expand("%"))
    local output = vim.fn.system(cmd .. " " .. file)
    print(vim.trim(output))
end

return M
