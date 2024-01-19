vim.cmd("set loadplugins")

require("ft")

require("ui")

require("config")

vim.defer_fn(function()
    require("theme")
end, 20)
