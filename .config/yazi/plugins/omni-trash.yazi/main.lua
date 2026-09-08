--- @since 25.12.29

local toggle_ui = ya.sync(function(st)
    if st.children then
        Modal:children_remove(st.children)
        st.children = nil
    else
        st.children = Modal:children_add(st, 10)
    end
    ui.render()
end)

local update_items = ya.sync(function(st, items)
    st.items = items
    st.cursor = math.max(0, math.min(st.cursor or 0, #st.items - 1))
    ui.render()
end)

local update_cursor = ya.sync(function(st, step)
    if not st.items or #st.items == 0 then
        st.cursor = 0
    else
        st.cursor = ya.clamp(0, st.cursor + step, #st.items - 1)
    end
    ui.render()
end)

local get_active_item = ya.sync(function(st)
    return st.items and st.items[(st.cursor or 0) + 1]
end)

local M = {
    keys = {
        { on = "q",      run = "quit" },
        { on = "<Esc>",  run = "quit" },
        { on = "k",      run = "up" },
        { on = "<Up>",   run = "up" },
        { on = "j",      run = "down" },
        { on = "<Down>", run = "down" },
        { on = "r",      run = "restore" },
        { on = "E",      run = "empty" },
    },
}

function M:new(area)
    self:layout(area)
    return self
end

function M:layout(area)
    local chunks = ui.Layout()
        :direction(ui.Layout.VERTICAL)
        :constraints({
            ui.Constraint.Percentage(12),
            ui.Constraint.Percentage(76),
            ui.Constraint.Percentage(12),
        })
        :split(area)

    local hchunks = ui.Layout()
        :direction(ui.Layout.HORIZONTAL)
        :constraints({
            ui.Constraint.Percentage(5),
            ui.Constraint.Percentage(90),
            ui.Constraint.Percentage(5),
        })
        :split(chunks[2])

    self._area = hchunks[2]
end

function M:redraw()
    if not self._area then return {} end
    local count = #(self.items or {})
    local title = "  r Restore   E Empty  "

    local rows = {}
    for i, item in ipairs(self.items or {}) do
        rows[i] = ui.Row {
            item.name,
            item.drive,
            item.date .. " " .. item.time,
            item.path,
        }
    end

    return {
        ui.Clear(self._area),
        ui.Border(ui.Edge.ALL)
            :area(self._area)
            :type(ui.Border.ROUNDED)
            :style(ui.Style():fg("blue"))
            :title(ui.Line(title):align(ui.Align.CENTER)),
        ui.Table(rows)
            :area(self._area:pad(ui.Pad(1, 2, 1, 2)))
            :header(ui.Row({ "Name (" .. count .. ")", "Drive", "Deleted At", "Original Path" }):style(ui.Style():bold()))
            :row(self.cursor)
            :row_style(ui.Style():fg("cyan"):underline())
            :widths {
                ui.Constraint.Percentage(20),
                ui.Constraint.Percentage(15),
                ui.Constraint.Percentage(20),
                ui.Constraint.Percentage(45),
            },
    }
end

function M:reflow() return { self } end

function M:click() end

function M:scroll() end

function M:touch() end

function M.obtain()
    -- --all is required because garbage otherwise lists only entries whose
    -- original paths are below Yazi's current directory. JSON keeps parsing
    -- independent of the human-readable table's column spacing.
    local output, err = Command("garbage")
        :arg({ "list", "--all", "--json" })
        :output()
    if err or not output or not output.status.success then return {} end

    local decoded = ya.json_decode(output.stdout)
    if type(decoded) ~= "table" then return {} end

    local items = {}
    for index, entry in ipairs(decoded) do
        local path = tostring(entry.path or "")
        local date, time = tostring(entry.deletion_date or ""):match("^(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d:%d%d)")
        if path ~= "" then
            local drive = "Home"
            local mount = path:match("^/run/media/[^/]+/([^/]+)")
                or path:match("^/mnt/([^/]+)")
                or path:match("^/Volumes/([^/]+)")
            if mount then drive = mount end

            table.insert(items, {
                name = path:match("([^/]+)$") or path,
                drive = drive,
                path = path,
                date = date or "",
                time = time or "",
                -- garbage restore --all uses this same deletion-date ordering.
                restore_index = index - 1,
            })
        end
    end

    -- Keep garbage's original ascending order so restore_index remains valid.
    return items
end

local function command_error(err, output)
    if err then return tostring(err) end
    if output and output.stderr and output.stderr ~= "" then
        return output.stderr
    end
    return "unknown error"
end

function M:entry(job)
    local output = Command("garbage"):arg("--version"):output()
    if not output or not output.status.success then
        return ya.notify {
            title = "Omni Trash",
            content = "garbage not found. Please install it to use this plugin.",
            timeout = 5,
            level = "error",
        }
    end

    toggle_ui()
    update_items(self.obtain())

    while true do
        local key_idx = ya.which { cands = self.keys, silent = true }
        if not key_idx then break end
        local run = self.keys[key_idx].run
        if run == "quit" then
            break
        elseif run == "up" then
            update_cursor(-1)
        elseif run == "down" then
            update_cursor(1)
        elseif run == "restore" then
            local item = get_active_item()
            if item then
                -- garbage restore normally launches fzf when it is installed. Run
                -- the absolute garbage executable with an empty PATH to force its
                -- numeric prompt, then feed it the index selected in this modal.
                local out, err = Command("sh")
                    :arg({
                        "-c",
                        'bin=$(command -v garbage) || exit 127; printf "%s\\n" "$1" | env PATH= "$bin" restore --all',
                        "--",
                        tostring(item.restore_index),
                    })
                    :output()
                if out and out.status.success then
                    ya.notify { title = "Omni Trash", content = "Restored: " .. item.name, timeout = 3 }
                    update_items(self.obtain())
                else
                    ya.notify {
                        title = "Omni Trash",
                        content = "Restore failed: " .. command_error(err, out),
                        timeout = 5,
                        level = "error",
                    }
                end
            end
        elseif run == "empty" then
            local ok = ya.which {
                title = "Empty ALL trash? (cannot be undone)",
                cands = {
                    { on = "y", desc = "Yes, delete everything" },
                    { on = "n", desc = "No, cancel" },
                },
            }
            if ok == 1 then
                local out, err = Command("garbage")
                    :arg({ "empty", "--all" })
                    :output()
                if out and out.status.success then
                    ya.notify { title = "Omni Trash", content = "All trash cleared.", timeout = 3 }
                    update_items(self.obtain())
                else
                    ya.notify {
                        title = "Omni Trash",
                        content = "Empty failed: " .. command_error(err, out),
                        timeout = 5,
                        level = "error",
                    }
                end
            end
        end
    end

    toggle_ui()
end

return M
