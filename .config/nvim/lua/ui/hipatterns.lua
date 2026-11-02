-- Highlight #rrggbb colours and TODO/FIXME/HACK/NOTE in visible lines.
local api = vim.api
local ns = api.nvim_create_namespace("Hipatterns")

local keywords = {
    TODO  = "MiniHipatternsTodo",
    FIXME = "MiniHipatternsFixme",
    HACK  = "MiniHipatternsHack",
    NOTE  = "MiniHipatternsNote",
}

local hex_groups = {}

local function hex_group(hex)
    hex = hex:lower()
    if not hex_groups[hex] then
        local n = tonumber(hex, 16)
        local r, g, b = bit.rshift(n, 16), bit.band(bit.rshift(n, 8), 0xff), bit.band(n, 0xff)
        local light = 0.299 * r + 0.587 * g + 0.114 * b > 127.5
        hex_groups[hex] = "Hipatterns_" .. hex
        api.nvim_set_hl(0, hex_groups[hex], { bg = "#" .. hex, fg = light and "#000000" or "#ffffff" })
    end
    return hex_groups[hex]
end

local function mark(buf, row, s, e, group)
    api.nvim_buf_set_extmark(buf, ns, row, s - 1, {
        end_col = e - 1, hl_group = group, ephemeral = true, priority = 200,
    })
end

api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
        return not vim.b[buf].minihipatterns_disable
    end,
    on_line = function(_, _, buf, row)
        local line = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        if not line then return end
        for s, word, e in line:gmatch("()%f[%w](%u+)%f[%W]()") do
            if keywords[word] then mark(buf, row, s, e, keywords[word]) end
        end
        for s, hex, e in line:gmatch("()#(%x%x%x%x%x%x)%f[%X]()") do
            mark(buf, row, s, e, hex_group(hex))
        end
    end,
})

api.nvim_create_autocmd("ColorScheme", {
    group = api.nvim_create_augroup("Hipatterns", { clear = true }),
    callback = function() hex_groups = {} end,
})
