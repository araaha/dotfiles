local M = {}
local PackageName = "Jumplist"

--- Maximum number of entries kept per direction, per tab.
local DEFAULT_LIMIT = 100

---@enum STATE
local STATE = {
    INITIALIZED = "initialized",
    LIMIT = "limit",
    TABS = "tabs",
}

--- Whether `ps.sub()` already ran in this Lua VM. Re-subscribing the same kind
--- throws, so `setup()` has to be idempotent.
local subscribed = false

local function notify_error(s, ...)
    ya.notify({ title = PackageName, content = string.format(s, ...), timeout = 5, level = "error" })
end

--- Cwd of the tab with the given id, or `nil` if that tab is gone.
--- Sync context only.
---@param id integer
---@return string?
local function tab_cwd(id)
    for i = 1, #cx.tabs do
        local tab = cx.tabs[i]
        if tab.id.value == id then
            return tostring(tab.current.cwd)
        end
    end
end

--- Forget the tabs that have been closed, so their stacks don't leak.
--- Sync context only.
---@param tabs table<integer, table>
local function prune(tabs)
    local alive = {}
    for i = 1, #cx.tabs do
        alive[cx.tabs[i].id.value] = true
    end

    for id in pairs(tabs) do
        if not alive[id] then
            tabs[id] = nil
        end
    end
end

--- Jumplist of a single tab, created on first use.
---@param state table
---@param id integer
---@return { back: string[], current: string?, forward: string[] }
local function record_of(state, id)
    state[STATE.TABS] = state[STATE.TABS] or {}

    local record = state[STATE.TABS][id]
    if not record then
        record = { back = {}, forward = {} }
        state[STATE.TABS][id] = record
    end

    return record
end

--- Drop the oldest entries until the stack fits within `limit`.
---@param stack string[]
---@param limit integer
local function trim(stack, limit)
    while #stack > limit do
        table.remove(stack, 1)
    end
end

local active_tab = ya.sync(function()
    return cx.active.id.value
end)

local initialized = ya.sync(function(state)
    return state[STATE.INITIALIZED] == true
end)

local init_state = ya.sync(function(state, limit)
    state[STATE.LIMIT] = limit
    -- Keep any stacks already collected, so calling `setup()` twice isn't destructive.
    state[STATE.TABS] = state[STATE.TABS] or {}
    state[STATE.INITIALIZED] = true
end)

--- Record a directory change for the tab it actually happened in.
local on_cd = ya.sync(function(state, id)
    local cwd = tab_cwd(id)
    if not cwd then
        return
    end

    local record = record_of(state, id)

    if not record.current then
        record.current = cwd
    elseif record.current ~= cwd then
        table.insert(record.back, record.current)
        trim(record.back, state[STATE.LIMIT] or DEFAULT_LIMIT)

        record.current = cwd
        record.forward = {}
    end

    prune(state[STATE.TABS])
end)

local peek = ya.sync(function(state, id, direction)
    local stack = record_of(state, id)[direction]
    return stack[#stack]
end)

--- Discard the top entry of a stack without moving the current position,
--- used to skip directories that no longer exist.
local discard = ya.sync(function(state, id, direction)
    table.remove(record_of(state, id)[direction])
end)

--- Move to the top of `direction`, pushing the current directory onto the
--- opposite stack. Returns `false` if the stack changed since it was peeked.
local commit = ya.sync(function(state, id, direction, expected)
    local record = record_of(state, id)
    local stack = record[direction]

    if stack[#stack] ~= expected then
        return false
    end

    local opposite = direction == "back" and record.forward or record.back
    if record.current then
        table.insert(opposite, record.current)
        trim(opposite, state[STATE.LIMIT] or DEFAULT_LIMIT)
    end

    record.current = table.remove(stack)
    return true
end)

---@param direction "back"|"forward"
local function jump(direction)
    local id = active_tab()

    while true do
        local target = peek(id, direction)
        if not target then
            notify_error("No more entries in the %s stack.", direction)
            return
        end

        local cha = fs.cha(Url(target))
        if not cha or not cha.is_dir then
            -- The directory is gone; drop it and try the one behind it.
            discard(id, direction)
        elseif commit(id, direction, target) then
            ya.emit("cd", { Url(target) })
            return
        end
    end
end

---@class SetupOptions
---@field limit? integer Maximum entries kept per direction, per tab. Defaults to 100.

--- Setup plugin, add it to yazi/init.lua file
---@param opts? SetupOptions
function M:setup(opts)
    if opts ~= nil and type(opts) ~= "table" then
        notify_error("setup() expects a table of options, got %s.", type(opts))
        return
    end

    local limit = opts and opts.limit or DEFAULT_LIMIT
    if type(limit) ~= "number" or limit < 1 then
        notify_error("`limit` must be a positive number, got %s.", tostring(limit))
        limit = DEFAULT_LIMIT
    end

    init_state(limit)

    if not subscribed then
        ps.sub("cd", function(body)
            on_cd(body.tab)
        end)
        subscribed = true
    end
end

function M:entry(job)
    if not initialized() then
        notify_error('Not set up. Add `require("jumplist"):setup()` to your init.lua.')
        return
    end

    local direction = job.args.direction

    if direction ~= "back" and direction ~= "forward" then
        notify_error("Invalid direction: %s. Use 'back' or 'forward'.", tostring(direction))
        return
    end

    jump(direction)
end

return M
