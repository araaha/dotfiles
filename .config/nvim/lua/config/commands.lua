vim.api.nvim_create_user_command("Output", function(opts)
    -- Strip leading "!"
    local cmd = opts.args:gsub("^!", "")

    -- Run the shell command
    local output = vim.fn.system(cmd)

    -- Create a scratch buffer
    vim.cmd.enew()
    vim.bo.buftype = "nofile"

    -- Put output into the buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
end, { nargs = "+" })
