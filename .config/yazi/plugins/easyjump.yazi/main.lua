--- @since 25.12.29

-- Default legacy two-set hint key configuration
-- IMPORTANT: first_keys and second_keys must NOT overlap when using this mode
-- stylua: ignore
local DEFAULT_FIRST_KEYS = {
    "a", "s", "d", "f", "g", "e", "r", "c", "w", "t", "v", "x", "b", "q"
}

-- stylua: ignore
local DEFAULT_SECOND_KEYS = {
    "u", "i", "o", "h", "j", "k", "l", "n", "p", "y", "m"
}

-- Default single labels (for backward compatibility with original order)
-- stylua: ignore
local DEFAULT_SINGLE_LABELS = {
    "p", "b", "e", "t", "a", "o", "i", "n", "s", "r", "h", "l", "d", "c",
    "u", "m", "f", "g", "w", "v", "k", "j", "x", "y", "q"
}

-- Default double labels (for backward compatibility with original order)
-- stylua: ignore
local DEFAULT_DOUBLE_LABELS = {
    "au", "ai", "ao", "ah", "aj", "ak", "al", "an",
    "su", "si", "so", "sh", "sj", "sk", "sl", "sn",
    "du", "di", "do", "dh", "dj", "dk", "dl", "dn",
    "fu", "fi", "fo", "fh", "fj", "fk", "fl", "fn",
    "gu", "gi", "go", "gh", "gj", "gk", "gl", "gn",
    "eu", "ei", "eo", "eh", "ej", "ek", "el", "en",
    "ru", "ri", "ro", "rh", "rj", "rk", "rl", "rn",
    "cu", "ci", "co", "ch", "cj", "ck", "cl", "cn",
    "wu", "wi", "wo", "wh", "wj", "wk", "wl", "wn",
    "tu", "ti", "to", "th", "tj", "tk", "tl", "tn",
    "vu", "vi", "vo", "vh", "vj", "vk", "vl", "vn",
    "xu", "xi", "xo", "xh", "xj", "xk", "xl", "xn",
    "bu", "bi", "bo", "bh", "bj", "bk", "bl", "bn",
    "qu", "qi", "qo", "qh", "qj", "qk", "ql", "qn",
    "ap", "ay", "am", "sp", "sy", "sm", "dp", "dy",
    "dm", "fp", "fy", "fm", "gp", "gy", "gm", "ep",
    "ey", "em", "rp", "ry", "rm", "cp", "cy", "cm",
    "wp", "wy", "wm", "tp", "ty", "tm", "vp", "vy",
    "vm", "xp", "xy", "xm", "bp", "by", "bm", "qp",
    "qy", "qm",
}

---@param str string
---@return string[]
local function string_to_table(str)
    local result = {}
    for i = 1, #str do
        table.insert(result, str:sub(i, i))
    end
    return result
end

---@param keys string|string[]
---@return string[]
local function normalize_keys(keys)
    if type(keys) == "string" then
        return string_to_table(keys)
    end
    return keys
end

--- Generate single labels from first_keys and second_keys combined
---@param first_keys string[]
---@param second_keys string[]
---@return string[]
local function generate_single_labels(first_keys, second_keys)
    local labels = {}
    -- Add all first_keys
    for _, k in ipairs(first_keys) do
        table.insert(labels, k)
    end
    -- Add all second_keys
    for _, k in ipairs(second_keys) do
        table.insert(labels, k)
    end
    return labels
end

--- Generate double labels from first_keys × second_keys
---@param first_keys string[]
---@param second_keys string[]
---@return string[]
local function generate_double_labels(first_keys, second_keys)
    local labels = {}
    for _, fk in ipairs(first_keys) do
        for _, sk in ipairs(second_keys) do
            table.insert(labels, fk .. sk)
        end
    end
    return labels
end

--- Generate input key candidates
---@param first_keys string[]
---@param second_keys string[]
---@return string[]
local function generate_input_keys(first_keys, second_keys)
    local keys = {}
    local seen = {}
    -- Add all first_keys
    for _, k in ipairs(first_keys) do
        if not seen[k] then
            table.insert(keys, k)
            seen[k] = true
        end
    end

    -- Add all second_keys
    for _, k in ipairs(second_keys) do
        if not seen[k] then
            table.insert(keys, k)
            seen[k] = true
        end
    end

    -- Add control keys
    table.insert(keys, "<C-c>")
    table.insert(keys, "<Backspace>")
    return keys
end

--- Build lookup table from label list
---@param labels string[]
---@return table<string, number>
local function build_label_lookup(labels)
    local lookup = {}
    for i, v in ipairs(labels) do
        lookup[v] = i
    end
    return lookup
end

--- Build input candidates for ya.which
---@param input_keys string[]
---@return table[]
local function build_input_cands(input_keys)
    local cands = {}
    for _, v in ipairs(input_keys) do
        table.insert(cands, { on = v })
    end
    return cands
end

--- Validate that first_keys and second_keys don't overlap
---@param first_keys string[]
---@param second_keys string[]
---@return boolean, string?
local function validate_keys(first_keys, second_keys)
    local first_set = {}
    for _, k in ipairs(first_keys) do
        first_set[k] = true
    end
    for _, k in ipairs(second_keys) do
        if first_set[k] then
            return false,
                "Key '"
                .. k
                .. "' appears in both first_keys and second_keys. They must not overlap."
        end
    end
    return true, nil
end

local status_ej = function()
end

---@param ctx easyjump.InitResult
---@param file_index number
local function jump_to_file(ctx, file_index)
    local target = ctx.visible_files[file_index]
    if not target then
        return false
    end

    if target.pane == "current" then
        ya.emit("arrow", {
            target.cursor_pos - ctx.cursor - 1 + ctx.offset,
        })
    else
        ya.emit("reveal", { target.url })
    end
    return true
end

---@param st easyjump.state
local toggle_ui = ya.sync(function(st)
    if st.entity_label_id or st.status_ej_id then
        Entity:children_remove(st.entity_label_id)
        Status:children_remove(st.status_ej_id)
        st.entity_label_id = nil
        st.status_ej_id = nil
        Entity._inc = Entity._inc - 1
        Status._inc = Status._inc - 1
        ui.render()
        return cx.active.preview.folder ~= nil
    end

    local entity_label = function(self)
        local file = self._file
        local pos = st.files_indices[tostring(file.url)]
        if not pos or pos > st.current_files_count then
            return ui.Line({})
        elseif st.current_files_count > #st.single_labels then
            local label = st.double_labels[pos]
            if st.double_first_key ~= nil then
                if label:sub(1, 1) ~= st.double_first_key then
                    return ui.Line({})
                end
                return ui.Line({
                    ui.Span(label:sub(2, 2)):reset():fg(st.opt_label_fg):bg(st.opt_first_key_bg),
                    ui.Span(" "):reset(),
                })
            end
            return ui.Line({
                ui.Span(label:sub(1, 1)):reset():fg(st.opt_label_fg):bg(st.opt_first_key_bg),
                ui.Span(label:sub(2, 2)):reset():fg(st.opt_label_fg):bg(st.opt_second_key_bg),
                ui.Span(" "):reset(),
            })
        else
            return ui.Line({
                ui.Span(st.single_labels[pos]):reset():fg(st.opt_label_fg):bg(st.opt_first_key_bg),
                ui.Span(" "):reset(),
            })
        end
    end
    st.entity_label_id = Entity:children_add(entity_label, 2001)

    st.status_ej_id = Status:children_add(status_ej, 1001, Status.LEFT)
    ui.render()
    return cx.active.preview.folder ~= nil
end)

local function refresh_preview(has_folder_preview)
    if has_folder_preview then
        ya.emit("peek", { force = true })
    end
end

---@param state easyjump.state
---@param str string?
local update_double_first_key = ya.sync(function(state, str)
    state.double_first_key = str
    ui.render()
    return cx.active.preview.folder ~= nil
end)

-- State machine for reading input keys
-- Each state is a separate function. Type annotations document which fields are used.

---@alias easyjump.SecondKeyResult
---| "backspace" go back to first key state
---| "cancelled" user cancelled
---| "jumped" successfully jumped to file

--- State: Single-key mode (≤25 files)
--- Waits for a single key press and jumps to the file
--- Uses: input_cands, input_keys, single_key_files, current_files_count, cursor, offset
---@param ctx easyjump.InitResult
local function read_single_key(ctx)
    while true do
        local cand = ya.which({ cands = ctx.input_cands, silent = true })

        if cand == nil then
            -- invalid key, wait for next
        elseif ctx.input_keys[cand] == "<C-c>" then
            return -- cancelled
        else
            local key = ctx.input_keys[cand]
            local file_index = ctx.single_key_files[key]
            if file_index and file_index <= ctx.current_files_count then
                if jump_to_file(ctx, file_index) then
                    return -- jumped
                end
            end
            -- invalid key for current file count, wait for next
        end
    end
end

--- State: Double-key mode - waiting for first key
--- Returns the first key pressed, or nil if cancelled
--- Uses: input_cands, input_keys, first_key_of_label
---@param ctx easyjump.InitResult
---@return string? first_key
local function read_double_first_key(ctx)
    while true do
        local cand = ya.which({ cands = ctx.input_cands, silent = true })

        if cand == nil then
            -- invalid key, wait for next
        elseif ctx.input_keys[cand] == "<C-c>" then
            return nil -- cancelled
        elseif ctx.input_keys[cand] == "<Backspace>" then
            -- already at first key state, ignore backspace
        else
            local key = ctx.input_keys[cand]
            if ctx.first_key_of_label[key] then
                refresh_preview(update_double_first_key(key))
                return key -- transition to second key state
            end
            -- invalid first key, wait for next
        end
    end
end

--- State: Double-key mode - waiting for second key
--- Returns the result of the second key input
--- Uses: input_cands, input_keys, double_key_files, current_files_count, cursor, offset
---@param ctx easyjump.InitResult
---@param first_key string
---@return easyjump.SecondKeyResult
local function read_double_second_key(ctx, first_key)
    while true do
        local cand = ya.which({ cands = ctx.input_cands, silent = true })

        if cand == nil then
            -- invalid key, wait for next
        elseif ctx.input_keys[cand] == "<C-c>" then
            return "cancelled"
        elseif ctx.input_keys[cand] == "<Backspace>" then
            refresh_preview(update_double_first_key(nil))
            return "backspace" -- transition back to first key state
        else
            local second_key = ctx.input_keys[cand]
            local double_key = first_key .. second_key
            local file_index = ctx.double_key_files[double_key]
            if file_index and file_index <= ctx.current_files_count then
                if jump_to_file(ctx, file_index) then
                    return "jumped"
                end
            end
            -- invalid second key, wait for next
        end
    end
end

--- Main input handler with explicit state machine
---@param ctx easyjump.InitResult
local function read_input(ctx)
    -- Single-key mode: direct jump with one key press
    if ctx.current_files_count <= #ctx.single_labels then
        read_single_key(ctx)
        return
    end

    -- Double-key mode: state machine with explicit transitions
    while true do
        -- State 1: Wait for first key
        local first_key = read_double_first_key(ctx)
        if not first_key then
            return -- cancelled
        end

        -- State 2: Wait for second key
        local result = read_double_second_key(ctx, first_key)
        if result == "jumped" or result == "cancelled" then
            return
        end
        -- result == "backspace": loop back to first key state
    end
end

---@class(exact) easyjump.state
---@field opt_label_fg string
---@field opt_first_key_bg string
---@field opt_second_key_bg string
---@field single_labels string[]
---@field double_labels string[]
---@field input_keys string[]
---@field single_key_files table<string, number>
---@field double_key_files table<string, number>
---@field input_cands table[]
---@field visible_files easyjump.VisibleFile[]
---@field entity_label_id number
---@field status_ej_id number
---@field files_indices table<string, number> # file url to index
---@field current_files_count number
---@field double_first_key string?

---@class easyjump.InitResult
---@field current_files_count number
---@field cursor number
---@field offset number
---@field first_key_of_label table<string, string>
---@field single_labels string[]
---@field input_keys string[]
---@field single_key_files table<string, number>
---@field double_key_files table<string, number>
---@field input_cands table[]
---@field visible_files easyjump.VisibleFile[]

---@class easyjump.VisibleFile
---@field url Url
---@field pane "parent"|"current"|"preview"
---@field cursor_pos number

-- init to record file position and the file num
---@param state easyjump.state
---@return easyjump.InitResult?
local init = ya.sync(function(state)
    state.files_indices = {}
    local first_key_of_label = {}
    local current = cx.active.current
    local visible_files = {}

    local function add_folder(pane, folder)
        if not folder then
            return
        end

        for cursor_pos, file in ipairs(folder.window) do
            local index = #visible_files + 1
            visible_files[index] = {
                url = file.url,
                pane = pane,
                cursor_pos = cursor_pos,
            }
            state.files_indices[tostring(file.url)] = index
        end
    end

    add_folder("parent", cx.active.parent)
    add_folder("current", current)
    add_folder("preview", cx.active.preview.folder)

    state.visible_files = visible_files
    state.current_files_count = #visible_files

    if state.current_files_count > #state.double_labels then
        ya.notify({
            title = "easyjump",
            content = "Too many visible files to label across all panes.",
            timeout = 5,
            level = "warn",
        })
        state.current_files_count = #state.double_labels
    end

    if state.current_files_count > #state.single_labels then
        for i = 1, state.current_files_count do
            first_key_of_label[state.double_labels[i]:sub(1, 1)] = ""
        end
    end

    return {
        current_files_count = state.current_files_count,
        cursor = current.cursor,
        offset = current.offset,
        first_key_of_label = first_key_of_label,
        single_labels = state.single_labels,
        input_keys = state.input_keys,
        single_key_files = state.single_key_files,
        double_key_files = state.double_key_files,
        input_cands = state.input_cands,
        visible_files = visible_files,
    }
end)

---@param state easyjump.state
local clear_state = ya.sync(function(state)
    state.files_indices = nil
    state.visible_files = nil
    state.current_files_count = nil
    state.double_first_key = nil
end)

return {
    ---@param state easyjump.state
    setup = function(state, opts)
        opts = opts or {}
        state.opt_label_fg = opts.label_fg or "black"
        state.opt_first_key_bg = opts.first_key_bg or opts.first_key_fg or "blue"
        state.opt_second_key_bg = opts.second_key_bg or opts.icon_fg or "yellow"

        -- A single key set can be used for both positions, for example:
        -- keys = "werasdfcvjlk"
        local shared_keys = opts.keys and normalize_keys(opts.keys) or nil
        local using_custom_keys = opts.first_keys ~= nil or opts.second_keys ~= nil
        local first_keys = normalize_keys(opts.first_keys or DEFAULT_FIRST_KEYS)
        local second_keys = normalize_keys(opts.second_keys or DEFAULT_SECOND_KEYS)

        if shared_keys then
            state.single_labels = shared_keys
            state.double_labels = generate_double_labels(shared_keys, shared_keys)
            state.input_keys = generate_input_keys(shared_keys, {})
        else
            -- The legacy two-set mode still requires disjoint sets.
            local valid, err = validate_keys(first_keys, second_keys)
            if not valid then
                ya.notify({
                    title = "easyjump",
                    content = err .. " Falling back to defaults.",
                    timeout = 5,
                    level = "error",
                })
                first_keys = DEFAULT_FIRST_KEYS
                second_keys = DEFAULT_SECOND_KEYS
                using_custom_keys = false
            end

            -- Preserve the original label order unless legacy custom keys are given.
            if using_custom_keys then
                state.single_labels = generate_single_labels(first_keys, second_keys)
                state.double_labels = generate_double_labels(first_keys, second_keys)
            else
                state.single_labels = DEFAULT_SINGLE_LABELS
                state.double_labels = DEFAULT_DOUBLE_LABELS
            end
            state.input_keys = generate_input_keys(first_keys, second_keys)
        end

        -- Build lookup tables
        state.single_key_files = build_label_lookup(state.single_labels)
        state.double_key_files = build_label_lookup(state.double_labels)
        state.input_cands = build_input_cands(state.input_keys)
    end,

    entry = function(_, _)
        local ctx = init()

        if ctx == nil or ctx.current_files_count == 0 then
            return
        end

        refresh_preview(toggle_ui())
        read_input(ctx)
        refresh_preview(toggle_ui())
        clear_state()
    end,
}
