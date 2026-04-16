local preview_windows = {}

local function close_all_previews()
    for _, win in ipairs(preview_windows) do
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    preview_windows = {}
end

local function preview_definition()
    -- encoding (fix warning)
    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
    local encoding = client and client.offset_encoding or "utf-16"

    local params = vim.lsp.util.make_position_params(nil, encoding)

    vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
        if not result or vim.tbl_isempty(result) then
            return
        end

        local data = result[1] or result
        local uri = data.targetUri or data.uri
        local range = data.targetRange or data.range
        if not uri or not range then return end

        local bufnr = vim.uri_to_bufnr(uri)
        vim.fn.bufload(bufnr)

        -- open floating window (enter it)
        local win = vim.api.nvim_open_win(bufnr, true, {
            relative = "cursor",
            width = 120,
            height = 10,
            border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
            row = 1,
            col = 0,
        })

        -- track it
        table.insert(preview_windows, win)

        -- jump cursor
        vim.api.nvim_win_set_cursor(win, {
            range.start.line + 1,
            range.start.character,
        })

        -- close ALL stacked previews
        local close_all = function()
            close_all_previews()
        end

        vim.keymap.set("n", "X", close_all, { buffer = bufnr, nowait = true })
    end)
end

vim.keymap.set("n", "gd", preview_definition)
