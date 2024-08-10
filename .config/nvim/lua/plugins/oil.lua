opts = {
    keymaps = {
        ["g?"] = "actions.show_help",
        [">"] = "actions.select",
        ["<"] = "actions.parent",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "<Esc>",
        ["X"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
    },
    skip_confirm_for_simple_edits = true,
}

return {
    "stevearc/oil.nvim",
    keys = {
        { "<Leader>o", "<cmd>Oil<CR>", mode = "n" }
    },
    opts = opts
}
