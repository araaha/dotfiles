local M = {}
local runners = {
    go = { "go", "run" },
    python = { "python" },
}

function M.run()
    local ft = vim.bo.filetype
    local cmd = runners[ft]
    if not cmd then
        print("No runner for filetype: " .. ft)
        return
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("Save the file before running it.", vim.log.levels.WARN)
        return
    end

    local args = vim.list_extend(vim.deepcopy(cmd), { file })
    local ok, err = pcall(vim.system, args, { text = true }, vim.schedule_wrap(function(result)
        local output = vim.trim(result.stdout or "")
        local errors = vim.trim(result.stderr or "")
        if output ~= "" then
            print(output)
        end
        if errors ~= "" then
            vim.notify(errors, result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
        end
        if result.code ~= 0 then
            vim.notify("Runner exited with code " .. result.code, vim.log.levels.ERROR)
        end
    end))
    if not ok then
        vim.notify("Could not start runner: " .. tostring(err), vim.log.levels.ERROR)
    end
end

return M
