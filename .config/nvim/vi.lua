vim.cmd("syntax off")

vim.o.swapfile = false
vim.o.undolevels = -1
vim.o.undoreload = 0
vim.o.list = false

require("ui.statusline")
