local command = vim.api.nvim_create_user_command
command("Output", function(opts)
    local cmd = opts.args
    local output

    if cmd:sub(1, 1) == "!" then
        -- External shell command
        cmd = cmd:sub(2)
        output = vim.fn.system(cmd)
    else
        -- Internal Vim command
        local ok, result = pcall(vim.api.nvim_exec2, cmd, { output = true })
        if ok then
            output = result.output
        else
            output = result
        end
    end

    -- Create a scratch buffer
    vim.cmd.enew()
    vim.bo.buftype = "nofile"
    -- Put output into the buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { trimempty = true }))
end, { nargs = "+" })

local function Run()
    local runners = {
        go = "go run",
        python = "python",
    }

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
command("Run", Run, {})
vim.keymap.set("n", "<Leader>ru", Run, {})
