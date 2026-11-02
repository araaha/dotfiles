-- Jump between the boundaries of the Tree-sitter node under the cursor.
local M = {}
local api = vim.api

local fallback_nodes = {
    comment = true,
    comment_content = true,
    attribute_value = true,
    block_comment = true,
    line_comment = true,
    string_content = true,
    string_fragment = true,
}

local function node_end(node)
    local _, _, row, col = node:range()
    -- Tree-sitter ranges are exclusive, including when they end at column 0.
    if col == 0 then
        row = math.max(row - 1, 0)
        col = #api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    end
    local line = api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    col = math.max(col - 1, 0)
    while col > 0 and (line:byte(col + 1) or 0) >= 128 and (line:byte(col + 1) or 0) < 192 do
        col = col - 1
    end
    return row, col
end

--- Returns the 0-indexed start and end positions of the node under the cursor,
--- and whether the cursor is on the end boundary.
function M.boundaries()
    local row, col = unpack(api.nvim_win_get_cursor(0))
    row = row - 1
    local line = api.nvim_get_current_line()
    if #line == 0 then return end
    col = math.min(col, #line - 1)
    if line:sub(1, col + 1):match("^%s+$") then
        col = (line:find("%S") or col + 1) - 1
    end

    local ok, parser = pcall(vim.treesitter.get_parser, 0)
    if not ok or not parser then return end
    local parsed = pcall(parser.parse, parser, { row, col })
    if not parsed then return end
    local node = parser:named_node_for_range({ row, col, row, col }, { ignore_injections = false })
    if not node or fallback_nodes[node:type()] then return end

    -- Only promote a leaf delimiter, not every named node, to its parent.
    if node:child_count() == 0 and line:sub(col + 1, col + 1):match("[%[%](){}<>\"'`]") then
        node = node:parent() or node
    end
    local first, last = node:child(0), node:child(node:child_count() - 1)
    if first and last and not first:equal(last) then
        local sr, sc = first:range()
        local er, ec = node_end(last)
        return { sr, sc }, { er, ec }, vim.treesitter.is_in_node_range(last, row, col)
    end

    local sr, sc = node:range()
    local er, ec = node_end(node)
    return { sr, sc }, { er, ec }, row == er and col == ec
end

function M.jump()
    -- Keep Vim's percentage-of-file motion (e.g. 50%).
    if vim.v.count > 0 then
        vim.cmd.normal({ args = { vim.v.count .. "%" }, bang = true })
        return
    end
    local first, last, backward = M.boundaries()
    if not first then
        vim.cmd.normal({ args = { "%" }, bang = true })
        return
    end
    -- Like %, include both delimiters when used as an operator motion.
    if api.nvim_get_mode().mode == "no" then vim.cmd.normal({ args = { "v" }, bang = true }) end
    vim.cmd("normal! m'")
    local pos = backward and first or last
    api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

return M
