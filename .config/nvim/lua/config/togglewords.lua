local M = {}

M.pairs = {
    ["true"] = "false",
    ["false"] = "true",
}

-- Add custom pairs
function M.add_pair(a, b)
    M.pairs[a] = b
    M.pairs[b] = a
end

-- Lookup (both directions)
local function get_toggle(word)
    return M.pairs[word]
end

-- Replace word or fallback to real <C-a> or <C-x>
local function toggle_or_fallback(is_increment)
    local word = vim.fn.expand("<cword>")
    local replacement = get_toggle(word)
    if replacement then
        vim.cmd("normal! ciw" .. replacement)
    else
        local key = is_increment and "<C-a>" or "<C-x>"
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
    end
end

function M.toggle_word() toggle_or_fallback(true) end

function M.toggle_word_reverse() toggle_or_fallback(false) end

M.add_pair("sh", "bash")
M.add_pair("on", "off")

vim.keymap.set("n", "<C-a>", M.toggle_word, { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>", M.toggle_word_reverse, { noremap = true, silent = true })

return M
