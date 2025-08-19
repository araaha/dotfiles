---@diagnostic disable: need-check-nil
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
    ["ntT"] = "(TERMINAL)",
    ["niI"] = "(INSERT)",
}

local set_hl = function(group, options)
    local bg = options.bg == nil and "" or "guibg=" .. options.bg
    local fg = options.fg == nil and "" or "guifg=" .. options.fg
    local gui = options.gui == nil and "" or "gui=" .. options.gui

    vim.cmd(string.format("hi %s %s %s %s", group, bg, fg, gui))
end

-- you can of course pick whatever colour you want, I picked these colours
-- because I use Gruvbox and I like them
local highlights = {
    { "StatuslineAccent",          { bg = "#7DAEA3", fg = "#242424" } },
    { "StatuslineInsertAccent",    { bg = "#9DC365", fg = "#242424" } },
    { "StatuslineVisualAccent",    { bg = "#D8A657", fg = "#242424" } },
    { "StatuslineReplaceAccent",   { bg = "#D3869B", fg = "#242424" } },
    { "StatuslineCmdLineAccent",   { bg = "#FE8019", fg = "#242424" } },
    { "StatuslineTerminalAccent",  { bg = "#E6DBAF", fg = "#242424" } },

    { "StatuslineAccentF",         { bg = "#242424", fg = "#7DAEA3" } },
    { "StatuslineInsertAccentF",   { bg = "#242424", fg = "#9DC365" } },
    { "StatuslineVisualAccentF",   { bg = "#242424", fg = "#D8A657" } },
    { "StatuslineReplaceAccentF",  { bg = "#242424", fg = "#D3869B" } },
    { "StatuslineCmdLineAccentF",  { bg = "#242424", fg = "#FE8019" } },
    { "StatuslineTerminalAccentF", { bg = "#242424", fg = "#E6DBAF" } },

    { "LspDiagnosticError",        { bg = "#fb4934", fg = "#242424" } },
    { "LspDiagnosticWarn",         { bg = "#fabd2f", fg = "#242424" } },
    { "LspDiagnosticInfo",         { bg = "#83a598", fg = "#242424" } },
    { "LspDiagnosticHint",         { bg = "#8ec07c", fg = "#242424" } },
    { "LspClient",                 { bg = "#FE8019", fg = "#242424" } },

    { "SepIcon",                   { bg = "#8ec07c", fg = "#ffffff" } },
}

for _, highlight in ipairs(highlights) do
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

local sep_icon = ""

local function mode()
    local current_mode = vim.api.nvim_get_mode().mode

    if vim.o.columns < 50 then
        return string.format(" %s %s%s", current_mode:upper(), sep_icon, update_mode_colors_foreground())
    end

    return string.format(" %s %s%s", modes[current_mode], sep_icon, update_mode_colors_foreground())
end

local function filetype()
    if vim.bo.filetype == "" then
        return ""
    end

    return "%#StatuslineReplaceAccent#" .. " %{&filetype} "
end

local function filepath(s)
    local fpath = vim.fn.expand("%")
    if fpath == "" or fpath == "." then
        return ""
    end

    local term = {}
    for word in fpath:gmatch("%S+") do
        table.insert(term, word)
    end

    local current_mode = vim.api.nvim_get_mode().mode
    if current_mode == "nt" or current_mode == "ntT" or current_mode == "t" then
        return string.format("%s%s", s, term[1])
    end

    if string.len(vim.fn.expand("%")) > 50 and vim.o.columns <= 80 then
        return string.format("%s%s", s, vim.fn.expand("%:t"))
    end

    if vim.o.columns <= 80 then
        return string.format("%s%s", s, vim.fn.expand("%:t"))
    end

    return string.format("%s%s%s", update_mode_colors_foreground(), s, fpath)
end

local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    if vim.o.columns < 50 then
        return "%#StatuslineAccent#" .. " %l/%L "
    end
    return "%#StatuslineAccent#" .. " %l/%L "
end

local function modified()
    return " %{&modified?\"\":\"\"} "
end

local function lsp()
    local count = {}
    local levels = {
        errors = 1,
        warnings = 2,
        info = 3,
        hints = 4,
    }

    for k, level in pairs(levels) do
        count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
    end

    local errors = ""
    local warnings = ""
    local hints = ""
    local info = ""

    if count["errors"] ~= 0 then
        errors = string.format(" %s %d", "%#LspDiagnosticError# ", count["errors"])
    end
    if count["warnings"] ~= 0 then
        warnings = string.format(" %s %d", "%#LspDiagnosticWarn# ", count["warnings"])
    end
    if count["hints"] ~= 0 then
        hints = string.format(" %s %d", "%#LspDiagnosticHint# ", count["hints"])
    end
    if count["info"] ~= 0 then
        info = string.format(" %s %d", "%#LspDiagnosticInfo# ", count["info"])
    end

    if vim.o.columns < 50 then
        return ""
    end
    return string.format("%s%s%s%s ", errors, warnings, hints, info)
end

local function get_lsp_clients()
    local clients = vim.lsp.get_clients()
    if next(clients) == nil then
        return ""
    end

    if vim.o.columns < 50 then
        return ""
    end

    local c = {}
    for _, client in pairs(clients) do
        table.insert(c, client.name)
    end
    return "%#LspClient#" .. string.format(" %s ", table.concat(c, "|"))
end

local countdown = ""

local function pomo()
    local timer = vim.uv.new_timer()

    local function getTime()
        local time = vim.fn.system("uairctl fetch {time}\n")
        local res = ""
        if time and #time > 0 and vim.v.shell_error == 0 then
            res = time
        end
        return res
    end

    local function zero()
        local time = getTime()
        if not time or #time == 0 then
            countdown = ""
            timer:stop()
            return
        else
            countdown = string.format("%%#StatuslineInsertAccent# %s", time)
        end

        vim.cmd.redrawstatus()
        if time == "00:00" then
            vim.cmd("CellularAutomaton game_of_life")
            vim.defer_fn(function()
                vim.cmd("bdelete!")
                vim.opt_local.statusline = "%{%v:lua.Statusline.active()%}"
            end, 3000)
            return
        end
    end

    timer:start(0, 1000, vim.schedule_wrap(zero))
end

pomo()

Statusline = {}

Statusline.active = function()
    return table.concat {
        update_mode_colors(),
        mode(),
        filepath(" "),
        modified(),
        "%=",
        countdown,
        lsp(),
        get_lsp_clients(),
        filetype(),
        lineinfo(),
    }
end

Statusline.inactive = function()
    return string.format("%s", filepath(""))
end

local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

vim.opt_local.statusline = "%{%v:lua.Statusline.active()%}"

au({ "WinEnter", "BufEnter" },
    {
        group = ag("StatusLine", { clear = false }),
        callback = function()
            vim.opt_local.statusline = "%{%v:lua.Statusline.active()%}"
        end
    })

au({ "WinLeave", "BufLeave" },
    {
        group = ag("StatusLine", { clear = false }),
        callback = function()
            vim.opt_local.statusline = "%{%v:lua.Statusline.inactive()%}"
        end

    })
