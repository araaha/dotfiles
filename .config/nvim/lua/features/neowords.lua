local M = {}
local fn = vim.fn

-- Subwords, numbers, hex colours and runs of '='; punctuation is skipped.
local pattern = "\\C\\v(" .. table.concat({
    "[[:upper:][:lower:]]@<![[:lower:]]+(#[[:xdigit:]]+)@<!",
    "[[:upper:]][[:lower:]]+(#[[:xdigit:]]+)@<!",
    "[[:upper:]]@<![[:upper:]]+(#[[:xdigit:]]+)@<![[:lower:]]@!",
    "[[:digit:]]@<![[:digit:]]+(#[[:xdigit:]]+)@<!",
    "#([[:xdigit:]]{8}|[[:xdigit:]]{6}|[[:xdigit:]]{4}|[[:xdigit:]]{3})[[:alnum:]]@!",
    "\\=@<!\\=+",
}, "|") .. ")"

local flags = { w = "W", e = "We", b = "Wb", ge = "Wbe" }

function M.jump(key, count)
    for _ = 1, count do
        if fn.search(pattern, flags[key]) == 0 then break end
    end
    if fn.mode() == "n" then
        for _, value in ipairs(vim.opt.foldopen:get()) do
            if value == "hor" or value == "all" then
                vim.cmd("normal! zv")
                break
            end
        end
    end
end

function M.motion(key)
    local pending = fn.mode(1):sub(1, 2) == "no"
    if fn.search(pattern, flags[key] .. "n") == 0 then
        return pending and "<Esc>" or ""
    end
    -- End motions are inclusive. Embed the count for operator dot-repeat.
    local inclusive = pending and (key == "e" or key == "ge") and "v" or ""
    return ("%s<Cmd>lua require('features.neowords').jump(%q, %d)<CR>")
        :format(inclusive, key, vim.v.count1)
end

return M
