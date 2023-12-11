local modes = {
    ["n"] = "NORMAL",
    ["no"] = "NORMAL",
    ["v"] = "VISUAL",
    ["V"] = "VISUAL LINE",
    [""] = "VISUAL BLOCK",
    ["s"] = "SELECT",
    ["S"] = "SELECT LINE",
    [""] = "SELECT BLOCK",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rv"] = "VISUAL REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "VIM EX",
    ["ce"] = "EX",
    ["r"] = "PROMPT",
    ["rm"] = "MOAR",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["nt"] = "TERMINAL",
    ["t"] = "TERMINAL",
    ["niI"] = "(INSERT)",
}

local function mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(" %s ", modes[current_mode]):upper()
end

local set_hl = function(group, options)
    local bg = options.bg == nil and '' or 'guibg=' .. options.bg
    local fg = options.fg == nil and '' or 'guifg=' .. options.fg
    local gui = options.gui == nil and '' or 'gui=' .. options.gui

    vim.cmd(string.format('hi %s %s %s %s', group, bg, fg, gui))
end

-- you can of course pick whatever colour you want, I picked these colours
-- because I use Gruvbox and I like them
local highlights = {
    { 'StatuslineAccent',         { bg = "#7DAEA3", fg = "#242424" } },
    { 'StatuslineInsertAccent',   { bg = "#9DC365", fg = "#242424" } },
    { 'StatuslineVisualAccent',   { bg = "#D8A657", fg = "#242424" } },
    { 'StatuslineReplaceAccent',  { bg = "#D3869B", fg = "#242424" } },
    { 'StatuslineCmdLineAccent',  { bg = "#FE8019", fg = "#242424" } },
    { 'StatuslineTerminalAccent', { bg = "#E6DBAF", fg = "#242424" } },
}

for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
end

local highlights_foreground = {
    { 'StatuslineAccentF',         { bg = "#242424", fg = "#7DAEA3" } },
    { 'StatuslineInsertAccentF',   { bg = "#242424", fg = "#9DC365" } },
    { 'StatuslineVisualAccentF',   { bg = "#242424", fg = "#D8A657" } },
    { 'StatuslineReplaceAccentF',  { bg = "#242424", fg = "#D3869B" } },
    { 'StatuslineCmdLineAccentF',  { bg = "#242424", fg = "#FE8019" } },
    { 'StatuslineTerminalAccentF', { bg = "#242424", fg = "#E6DBAF" } },
}

for _, highlight in ipairs(highlights_foreground) do
    set_hl(highlight[1], highlight[2])
end

local function update_mode_colors_foreground()
    local current_mode = vim.api.nvim_get_mode().mode
    local mode_color = "%#StatuslineAccentF#"
    if current_mode == "n" then
        mode_color = "%#StatuslineAccentF#"
    elseif current_mode == "i" or current_mode == "ic" or current_mode == "niI" then
        mode_color = "%#StatuslineInsertAccentF#"
    elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
        mode_color = "%#StatuslineVisualAccentF#"
    elseif current_mode == "R" then
        mode_color = "%#StatuslineReplaceAccentF#"
    elseif current_mode == "c" then
        mode_color = "%#StatuslineCmdLineAccentF#"
    elseif current_mode == "t" or current_mode == "nt" then
        mode_color = "%#StatuslineTerminalAccentF#"
    end
    return mode_color
end

local function update_mode_colors()
    local current_mode = vim.api.nvim_get_mode().mode
    local mode_color = "%#StatuslineAccent#"
    if current_mode == "n" then
        mode_color = "%#StatuslineAccent#"
    elseif current_mode == "i" or current_mode == "ic" or current_mode == "niI" then
        mode_color = "%#StatuslineInsertAccent#"
    elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
        mode_color = "%#StatuslineVisualAccent#"
    elseif current_mode == "R" then
        mode_color = "%#StatuslineReplaceAccent#"
    elseif current_mode == "c" then
        mode_color = "%#StatuslineCmdLineAccent#"
    elseif current_mode == "t" or current_mode == "nt" then
        mode_color = "%#StatuslineTerminalAccent#"
    end
    return mode_color
end

local function filepath()
    local fpath = vim.fn.expand("%")
    if fpath == "" or fpath == "." then
        return ""
    end

    return string.format("%s", fpath)
end

local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    return " %=%P %l:%c"
end

local function modified()
    return " %{&modified?\"[+]\":\"\"}"
end

Statusline = {}

Statusline.active = function()
    return table.concat {
        "%#StatusLine#",
        update_mode_colors(),
        mode(),
        "",
        "%#StatuslineFilepath# ",
        update_mode_colors_foreground(),
        filepath(),
        modified(),
        "%#StatuslineLine#",
        update_mode_colors_foreground(),
        lineinfo(),
    }
end

function Statusline.inactive()
    return " %F"
end

local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

au({ 'WinEnter', 'BufEnter', 'CursorMoved' },
    {
        group = ag('StatusLine', { clear = false }),
        callback = function()
            vim.opt_local.statusline = '%!v:lua.Statusline.active()'
        end
    })

au({ 'WinLeave', 'BufLeave' },
    {
        group = ag('StatusLine', { clear = false }),
        callback = function()
            vim.opt_local.statusline = '%!v:lua.Statusline.inactive()'
        end
    })
