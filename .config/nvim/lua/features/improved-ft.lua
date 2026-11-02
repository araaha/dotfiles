local M = {}
local api, fn = vim.api, vim.fn
local last

local function before(a, b)
    return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
end

-- Shift a position by one character, wrapping to the neighbouring line. Only
-- normal mode keeps the cursor off the end of the line.
local function shift(row, col, offset)
    if offset == 0 then return { row, col } end
    local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local index = fn.charidx(line, col) + offset
    local byte = fn.byteidx(line, index)
    local normal = api.nvim_get_mode().mode == "n"
    if index < 0 then
        if row == 1 then return { row, 0 } end
        row = row - 1
        line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        byte = normal and fn.byteidx(line, math.max(fn.strchars(line) - 1, 0)) or #line
    elseif byte == -1 or (normal and byte == #line) then
        if row == api.nvim_buf_line_count(0) then return { row, col } end
        row, byte = row + 1, 0
    end
    return { row, math.max(byte, 0) }
end

-- f/F land on the character, t lands before it and T after it. Targets that
-- don't move past the cursor are skipped, so repeated t/T don't get stuck.
local function find(char, key, count)
    local backward = key:match("%u") ~= nil
    local offset = key == "t" and -1 or (key == "T" and 1 or 0)
    local pattern = "\\V" .. fn.escape(char, "\\")
    local origin = api.nvim_win_get_cursor(0)
    local view = fn.winsaveview()
    local target
    while count > 0 and fn.search(pattern, backward and "bW" or "W") ~= 0 do
        local pos = shift(fn.line("."), fn.col(".") - 1, offset)
        if before(origin, pos) ~= backward and (pos[1] ~= origin[1] or pos[2] ~= origin[2]) then
            target, count = pos, count - 1
        end
    end
    fn.winrestview(view)
    -- Like improved-ft, use the furthest match if fewer than count exist.
    return target
end

function M.jump(nr, key, count)
    local target = find(fn.nr2char(nr), key, count)
    if target then api.nvim_win_set_cursor(0, target) end
end

function M.motion(key)
    local char
    if key == ";" or key == "," then
        if not last then return "" end
        local reverse = key == ","
        char, key = last.char, last.key
        if reverse then key = key:match("%u") and key:lower() or key:upper() end
    else
        local ok, input = pcall(fn.getcharstr)
        if not ok or input == "\27" then return "" end
        char = input
        last = { char = char, key = key }
    end

    local pending = fn.mode(1):sub(1, 2) == "no"
    if not find(char, key, 1) then
        return pending and "<Esc>" or ""
    end
    -- Forward motions are inclusive, like the builtin f/t.
    local force = pending and key:match("%l") and "v" or ""
    -- Embed the arguments so dot-repeat isn't affected by later motions.
    return ("%s<Cmd>lua require('features.improved-ft').jump(%d, %q, %d)<CR>")
        :format(force, fn.char2nr(char), key, vim.v.count1)
end

return M
