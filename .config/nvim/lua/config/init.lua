require("config.lazy")
require("config.autocmd")
require("config.options")

vim.schedule(function()
    require("config.commands")
    require("config.lsp")
    require("config.keymaps")
end)
