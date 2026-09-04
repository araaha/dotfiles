require("session"):setup({
    sync_yanked = true,
})

require("zoxide"):setup({
    update_db = true,
})

require("easyjump"):setup({
    first_key_fg = "lightblue",
    second_key_fg = "#d8a657",
    label_fg = "black"
})

require("jumplist"):setup({})

require("statusline"):setup({
    mode_normal = "#7daea3",
    position = "#7daea3",
    separator_open = " ",
    mode_select = "yellow",
    mode_unset = "white"
})
