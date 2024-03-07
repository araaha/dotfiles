local opts = {
    auto_enable = true,
    auto_resize_height = false, -- highly recommended enable
    magic_window = false,
    preview = {
        win_height = 3,
        auto_preview = false,
        show_scroll_bar = false,
        winblend = 0,
        delay_syntax = 80,
        wrap = true,
        border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
        show_title = false,
        should_preview_cb = function(bufnr)
            local ret = true
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local fsize = vim.fn.getfsize(bufname)
            if fsize > 100 * 1024 then
                -- skip file size greater than 100k
                ret = false
            elseif bufname:match("^fugitive://") then
                -- skip fugitive buffer
                ret = false
            end
            return ret
        end
    },
}

return {
    "kevinhwang91/nvim-bqf",
    version = false,
    ft = "qf",
    opts = opts,
}
