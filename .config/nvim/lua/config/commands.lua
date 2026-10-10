local command = vim.api.nvim_create_user_command

command("Output", function(opts)
    require("features.output").open(opts.args)
end, { nargs = "+", desc = "Capture command output in a scratch buffer" })

command("Run", function()
    require("features.runner").run()
end, { desc = "Run the current file" })

command("TSInstall", function(opts)
    require("features.treesitter_install").install(opts.bang)
end, { bang = true, desc = "Install all configured Tree-sitter parsers and queries" })

vim.api.nvim_create_autocmd("CmdUndefined", {
    group = vim.api.nvim_create_augroup("UserDeferredCommands", { clear = true }),
    pattern = "Undotree",
    callback = function() require("features.undotree").load() end,
    desc = "Load the bundled undo tree on its first command",
})
