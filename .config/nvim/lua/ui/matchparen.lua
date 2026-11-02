-- Highlight the matching delimiter pair around the cursor using Tree-sitter.
local api = vim.api
local boundaries = require("features.pairs").boundaries
local matches = {}

local delimiter_pairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ["<"] = ">",
    ['"'] = '"',
    ["'"] = "'",
    ["`"] = "`",
}

local function clear()
    local win = api.nvim_get_current_win()
    if matches[win] then
        pcall(vim.fn.matchdelete, matches[win], win)
        matches[win] = nil
    end
end

local function highlight()
    clear()
    if vim.bo.buftype ~= "" then return end
    local ok, first, last = pcall(boundaries)
    if not ok or not first or (first[1] == last[1] and first[2] == last[2]) then return end

    local positions, chars = {}, {}
    for _, pos in ipairs({ first, last }) do
        local line = api.nvim_buf_get_lines(0, pos[1], pos[1] + 1, false)[1] or ""
        chars[#chars + 1] = line:sub(pos[2] + 1, pos[2] + 1)
        positions[#positions + 1] = { pos[1] + 1, pos[2] + 1, 1 }
    end
    -- Node boundaries may also be identifiers or keywords, not actual pairs.
    if delimiter_pairs[chars[1]] == chars[2] then
        matches[api.nvim_get_current_win()] = vim.fn.matchaddpos("MatchParen", positions, 10)
    end
end

local group = api.nvim_create_augroup("Matchparen", { clear = true })
api.nvim_create_autocmd(
{ "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    callback = highlight,
})
api.nvim_create_autocmd({ "BufLeave", "WinLeave", "InsertEnter" }, {
    group = group,
    callback = clear,
})
highlight()
