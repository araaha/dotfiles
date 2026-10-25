local M = {}

local function find_lists(text)
    local stack, lists = {}, {}
    local quote, escaped
    local closing = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

    for i = 1, #text do
        local c = text:sub(i, i)

        if quote then
            if escaped then
                escaped = false
            elseif c == "\\" then
                escaped = true
            elseif c == quote then
                quote = nil
            end
        elseif c == '"' or c == "'" or c == "`" then
            quote = c
        elseif c == "(" or c == "[" or c == "{" then
            stack[#stack + 1] = { first = i, char = c, commas = {} }
        elseif c == "," and #stack > 0 then
            table.insert(stack[#stack].commas, i)
        elseif closing[c] then
            local list = table.remove(stack)
            if not list or list.char ~= closing[c] then
                return {}
            end

            list.last = i
            lists[#lists + 1] = list
        end
    end

    return lists
end

local function select_list(lists, cursor, line_end)
    local best, score

    -- Inner lists come first because they close before their parents.
    for _, list in ipairs(lists) do
        local contains = list.first <= cursor and list.last >= cursor
        local distance = -1

        if contains then
            distance = 0
        elseif list.first < line_end then
            distance = list.first - cursor
        end

        if distance >= 0 and (not score or distance < score) then
            best, score = list, distance
        end
    end

    return best
end

-- Convert a one-based byte offset to a zero-based buffer position.
local function position(text, byte)
    local before = text:sub(1, byte - 1)
    local _, newlines = before:gsub("\n", "")

    return newlines, #(before:match("[^\n]*$") or "")
end

-- Toggle the innermost bracketed list at the cursor, or the next one on this line.
function M.toggle()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local cursor = vim.api.nvim_buf_get_offset(0, row - 1) + col + 1
    local line_end = text:find("\n", cursor, true) or #text + 1
    local list = select_list(find_lists(text), cursor, line_end)

    if not list then
        return
    end

    local first_row, first_col = position(text, list.first)
    local last_row, last_col = position(text, list.last + 1)

    -- Join an existing multiline list.
    if first_row ~= last_row then
        local inside = text:sub(list.first + 1, list.last - 1)
        local joined = vim.trim(inside):gsub("%s*\n%s*", " ")

        vim.api.nvim_buf_set_text(0, first_row, first_col + 1, last_row, last_col - 1, { joined })
        return
    end

    -- Split at top-level commas, indenting arguments one level.
    local opening_line = vim.api.nvim_buf_get_lines(0, first_row, first_row + 1, false)[1]
    local indent = opening_line:match("^%s*")
    local indent_step = vim.bo.expandtab and string.rep(" ", vim.fn.shiftwidth()) or "\t"
    local padding = indent .. indent_step
    local lines = { text:sub(list.first, list.first) }
    local start = list.first + 1

    for _, comma in ipairs(list.commas) do
        lines[#lines + 1] = padding .. vim.trim(text:sub(start, comma))
        start = comma + 1
    end

    local last_argument = vim.trim(text:sub(start, list.last - 1))
    if last_argument ~= "" then
        lines[#lines + 1] = padding .. last_argument
    end

    if #lines == 1 then
        return
    end

    lines[#lines + 1] = indent .. text:sub(list.last, list.last)

    vim.api.nvim_buf_set_text(0, first_row, first_col, last_row, last_col, lines)
    vim.api.nvim_win_set_cursor(0, { row, col })
end

return M
