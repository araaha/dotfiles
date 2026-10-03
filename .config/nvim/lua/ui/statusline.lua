local modes = {
    ["n"] = "NORMAL",
    ["no"] = "NORMAL",
    ["v"] = "VISUAL",
    ["V"] = "VISUAL LINE",
    ["\x16"] = "VISUAL BLOCK",
    ["\x13"] = "SELECT BLOCK",
    ["s"] = "SELECT",
    ["S"] = "SELECT LINE",
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

local function setup_highlights()
    for _, highlight in ipairs(highlights) do
        vim.api.nvim_set_hl(0, highlight[1], highlight[2])
    end
end

local mode_accents = {
    i = "Insert",
    ic = "Insert",
    niI = "Insert",
    v = "Visual",
    V = "Visual",
    ["\x16"] = "Visual",
    R = "Replace",
    c = "CmdLine",
    t = "Terminal",
    nt = "Terminal",
}

local function mode_color(current_mode, foreground)
    return "%#Statusline" .. (mode_accents[current_mode] or "") .. "Accent" .. (foreground and "F" or "") .. "#"
end

local function mode(current_mode)
    local label = vim.o.columns < 50 and current_mode:upper() or modes[current_mode] or current_mode:upper()
    return string.format("%s %s %s", mode_color(current_mode), label, mode_color(current_mode, true))
end

local function filetype()
    if vim.bo.filetype == "" then
        return ""
    end

    return "%#StatuslineReplaceAccent#" .. " %{&filetype} "
end

local function filepath(prefix, current_mode)
    local fpath = vim.fn.expand("%")
    if fpath == "" or fpath == "." then
        return ""
    end

    if current_mode == "nt" or current_mode == "ntT" or current_mode == "t" then
        fpath = fpath:match("%S+") or fpath
    elseif vim.o.columns <= 80 then
        fpath = vim.fn.expand("%:t")
    end

    return mode_color(current_mode, true) .. prefix .. fpath:gsub("%%", "%%%%")
end

local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    return "%#StatuslineAccent#" .. " %l/%L "
end

local function modified()
    return " %{&modified?\"\":\"\"} "
end

local group = vim.api.nvim_create_augroup("StatusLine", { clear = true })
local lsp_status = { percentage = 0, active = false, revision = 0 }

vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(ev)
        local value = ev.data.params.value
        if not value then return end

        lsp_status.percentage = math.max(0, math.min(100, value.percentage or 0))
        lsp_status.active = true
        lsp_status.revision = lsp_status.revision + 1

        if value.kind == "end" then
            lsp_status.percentage = 100
            local revision = lsp_status.revision
            vim.defer_fn(function()
                if lsp_status.revision == revision then
                    lsp_status.active = false
                    vim.cmd.redrawstatus()
                end
            end, 800)
        end

        vim.cmd.redrawstatus()
    end,
})

local function lsp_progress()
    if vim.o.columns < 70 or vim.bo.filetype == "go" then
        return ""
    end

    if not lsp_status.active then
        return ""
    end

    local percent = lsp_status.percentage or 0

    local icon
    local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }
    if percent >= 100 then
        icon = ""
    else
        local frame = math.floor(percent / (100 / #spinners))
        frame = math.min(frame, #spinners - 1)
        icon = spinners[frame + 1]
    end

    local content = string.format(
        " %%<%s %d%%%% ",
        icon,
        percent
    )

    return "%#StatuslineAccent#" .. content
end

local diagnostic_types = {
    { "Error", "", vim.diagnostic.severity.ERROR },
    { "Warn", "", vim.diagnostic.severity.WARN },
    { "Hint", "", vim.diagnostic.severity.HINT },
    { "Info", "", vim.diagnostic.severity.INFO },
}

local function lsp()
    if vim.o.columns < 50 then return "" end
    local counts = vim.diagnostic.count(0)
    local parts = {}
    for _, diagnostic in ipairs(diagnostic_types) do
        local name, icon, severity = unpack(diagnostic)
        local count = counts[severity] or 0
        if count > 0 then
            parts[#parts + 1] = string.format("%%#LspDiagnostic%s# %s %d ", name, icon, count)
        end
    end
    return table.concat(parts)
end

local function get_lsp_clients()
    if vim.o.columns < 50 then
        return ""
    end
    local clients = vim.lsp.get_clients()
    if #clients == 0 then return "" end
    local c = {}
    for _, client in pairs(clients) do
        table.insert(c, client.name)
    end
    return "%#LspClient#" .. string.format(" %s ", table.concat(c, "|"))
end

local countdown = ""

if _G.Statusline and Statusline.timer then
    Statusline.timer:stop()
    Statusline.timer:close()
end
Statusline = {}

local function pomo()
    if vim.fn.executable("uairctl") == 0 then return end
    local timer = assert(vim.uv.new_timer())
    Statusline.timer = timer

    local function zero()
        if timer:is_closing() then return end
        local time = vim.fn.trim(vim.fn.system({ "uairctl", "fetch", "{time}" }))
        if vim.v.shell_error ~= 0 or time == "" then
            countdown = ""
            timer:stop()
            vim.cmd.redrawstatus()
            return
        else
            countdown = string.format("%%#StatuslineInsertAccent# %s ", time)
        end

        vim.cmd.redrawstatus()
        if time == "00:00" then
            timer:stop()
            vim.cmd("CellularAutomaton game_of_life")
            local animation_buffer = vim.api.nvim_get_current_buf()
            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(animation_buffer) then
                    vim.api.nvim_buf_delete(animation_buffer, { force = true })
                end
                vim.opt_local.statusline = "%{%v:lua.Statusline.active()%}"
            end, 3000)
            return
        end
    end

    timer:start(0, 1000, vim.schedule_wrap(zero))
end

pomo()

local function searchcount()
    if vim.v.hlsearch ~= 1 then return "" end
    local sc = vim.fn.searchcount()
    return vim.v.hlsearch == 1 and (sc.total or 0) > 0 and
        string.format("%%#StatuslineTerminalAccent# %s/%s ", sc.current or 0, sc.total) or ""
end

Statusline.active = function()
    local current_mode = vim.api.nvim_get_mode().mode
    return table.concat {
        mode(current_mode),
        filepath(" ", current_mode),
        modified(),
        "%=",
        searchcount(),
        countdown,
        lsp_progress(),
        lsp(),
        get_lsp_clients(),
        filetype(),
        lineinfo(),
    }
end

Statusline.inactive = function()
    return filepath("", vim.api.nvim_get_mode().mode)
end

setup_highlights()
vim.opt_local.statusline = "%{%v:lua.Statusline.active()%}"

for event, state in pairs({ WinEnter = "active", BufEnter = "active", WinLeave = "inactive", BufLeave = "inactive" }) do
    vim.api.nvim_create_autocmd(event, {
        group = group,
        callback = function()
            vim.opt_local.statusline = "%{%v:lua.Statusline." .. state .. "()%}"
        end,
    })
end

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = setup_highlights })
vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
        if Statusline.timer then
            Statusline.timer:stop()
            Statusline.timer:close()
            Statusline.timer = nil
        end
    end,
})
