local signs = {
    E = 'DiagnosticError',
    W = 'DiagnosticWarn',
    I = 'DiagnosticInfo',
    N = 'DiagnosticHint',
}

local fn = vim.fn

function _G.qftf(info)
    local items
    local ret = {}
    local bracket = '┃'
    local ns = vim.api.nvim_create_namespace("qftf")

    if info.quickfix == 1 then
        items = fn.getqflist({ id = info.id, items = 0, qfbufnr = 1 })
    else
        items = fn.getloclist(info.winid, { id = info.id, items = 0, qfbufnr = 1 })
    end

    local max_fname_len = 0
    local qfStr = '%s%s%s%s%3d%s%s'

    for i = info.start_idx, info.end_idx do
        local e = items.items[i]
        if e.valid == 1 and e.bufnr > 0 then
            local fname = vim.fn.fnamemodify(fn.bufname(e.bufnr), ":t")
            local fname_len = #fname
            if max_fname_len < fname_len then
                max_fname_len = fname_len
            end
        end
    end

    for i = info.start_idx, info.end_idx do
        local e = items.items[i]
        local fname = ''
        local str = ''
        if e.valid == 1 and e.bufnr > 0 then
            fname = vim.fn.fnamemodify(fn.bufname(e.bufnr), ":t")
            local lnum = e.lnum
            local lnum_size = #('%3d'):format(lnum)
            local text = ' ' .. e.text


            local qtype = e.type ~= '' and (e.type .. ' ') or ''
            local offset = string.rep(' ', max_fname_len + 1 - #fname)
            local bracket_size = #bracket

            local highlight_group = signs[e.type]
            if signs[e.type] == nil then
                highlight_group = ""
            end
            vim.schedule(function()
                vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, highlight_group, i - 1, 0, #qtype)
                vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, "GruvboxBlueBold",
                    i - 1,
                    #qtype,
                    #qtype + #fname
                )
                vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, "GruvboxAqua",
                    i - 1,
                    #qtype + #fname + #offset,
                    #qtype + #fname + #offset + bracket_size
                )
                vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, "GruvboxPurple",
                    i - 1,
                    #qtype + #fname + #offset + bracket_size,
                    #qtype + #fname + #offset + bracket_size + lnum_size
                )
                vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, "GruvboxAqua", i - 1,
                    #qtype + #fname + #offset + bracket_size + lnum_size,
                    #qtype + #fname + #offset + bracket_size + lnum_size + #bracket
                )
                --     vim.api.nvim_buf_add_highlight(items.qfbufnr, ns, highlight_group,
                --         i - 1, #qtype + #fname + #offset + bracket_size + lnum_size + bracket_size,
                --         #qtype + #fname + #offset + bracket_size + lnum_size + bracket_size + #text
                --     )
            end)

            str = qfStr:format(qtype, fname, offset, bracket, lnum, bracket, text)
        end
        table.insert(ret, str)
    end

    return ret
end

vim.o.qftf = '{info -> v:lua._G.qftf(info)}'

return {
    "kevinhwang91/nvim-bqf",
    version = false,
    ft = "qf",
    opts = {
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
    },
}
