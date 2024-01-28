-- require("ft")

require("ui")

require("config")

vim.filetype.add({
    extension = {
        conf = 'toml'
    }
})

vim.filetype.add({
    extension = {
        typ = 'typst'
    }
})
