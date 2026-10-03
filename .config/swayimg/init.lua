---@diagnostic disable-next-line: undefined-global
local swayimg = swayimg

local colors = {
    background = 0xff242424,
    foreground = 0xffebdbb2,
    selected = 0xff3c3836,
    mark = 0xffebdbb2,
}

swayimg.appid = "swayimg"
swayimg.mode = "viewer"
swayimg.antialiasing = true
swayimg.decoration = true
swayimg.overlay = false
swayimg.exif_orientation = true
swayimg.dnd_button = "MouseExtra"

swayimg.imagelist.order = "numeric"
swayimg.imagelist.reverse = false
swayimg.imagelist.recursive = false
swayimg.imagelist.adjacent = false
swayimg.imagelist.fsmon = true

swayimg.text.visible = false
swayimg.text.font = "MesloLGS NF Regular"
swayimg.text.size = 12
swayimg.text.spacing = 0
swayimg.text.padding = 6
swayimg.text.color = colors.foreground
swayimg.text.background = colors.background
swayimg.text.shadow = 0x00000000
swayimg.text.timeout = 0
swayimg.text.status_timeout = 3

-- swayimg.viewer.animation = true
swayimg.viewer.default_scale = "fit"
swayimg.viewer.default_position = "center"
swayimg.viewer.drag_button = "MouseMiddle"
swayimg.viewer.autocenter = true
swayimg.viewer.loop = false
swayimg.viewer.preload = 1
swayimg.viewer.history = 16
swayimg.viewer.mark_color = colors.mark
swayimg.viewer.text = {
    bottomleft = { "{name}  {frame.width}x{frame.height}  {scale}" },
    bottomright = { "{list.index}/{list.total}" },
}
swayimg.viewer.set_window_background(colors.background)
swayimg.viewer.set_image_background(colors.background)

swayimg.slideshow.timeout = 5
swayimg.slideshow.default_scale = "optimal"
swayimg.slideshow.default_position = "center"
swayimg.slideshow.loop = true
swayimg.slideshow.mark_color = colors.mark
swayimg.slideshow.text = {
    bottomleft = { "{name}  {frame.width}x{frame.height}" },
    bottomright = { "{list.index}/{list.total}" },
}
swayimg.slideshow.set_window_background(colors.background)

swayimg.gallery.thumb_size = 128
swayimg.gallery.aspect = "fit"
swayimg.gallery.padding_size = 4
swayimg.gallery.border_size = 2
swayimg.gallery.border_color = colors.foreground
swayimg.gallery.selected_scale = 1.0
swayimg.gallery.selected_color = colors.selected
swayimg.gallery.unselected_color = colors.background
swayimg.gallery.window_color = colors.background
swayimg.gallery.hover = false
swayimg.gallery.cache = 100
swayimg.gallery.preload = true
swayimg.gallery.embedded_thumb = true
swayimg.gallery.mark_color = colors.mark
swayimg.gallery.text = {
    bottomleft = { "{name}" },
    bottomright = { "{list.index}/{list.total}" },
}

swayimg.on_initialized(function()
    swayimg.set_window_size(800, 600)
end)

local zoom_levels = {
    0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90,
    1.00, 1.10, 1.20, 1.30, 1.40, 1.50, 1.60, 1.70, 1.80,
    1.90, 2.00, 2.20, 2.40, 2.60, 2.80, 3.00, 4.00, 5.00,
    6.00, 8.00, 10.00, 13.00, 16.00, 20.00, 25.00, 30.00,
    35.00, 40.00, 45.00,
}

local thumb_levels = { 32, 64, 96, 128, 160 }
local mark_anchor = nil
local alternate_path = nil
local current_path = nil
local prefix_token = 0
local checkerboard = false

local function status(message)
    swayimg.text.status = message
end

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function bind(mode, keys, handler)
    mode.on_key(keys, handler)
end

local function open_path(kind, path)
    if kind == "gallery" then
        return swayimg.gallery.select_path(path)
    end
    return swayimg.viewer.open_path(path)
end

local function current_image(kind)
    if kind == "gallery" then
        return swayimg.gallery.get_image()
    end
    return swayimg.viewer.get_image()
end

local function mark_current(kind, state)
    if kind == "gallery" then
        swayimg.gallery.mark_image(state)
    else
        swayimg.viewer.mark_image(state)
    end
end

local function toggle_mark(kind)
    local image = current_image(kind)
    if not image then return end
    local was_marked = image.mark
    mark_current(kind)
    if not was_marked then mark_anchor = image.index end
end

local function apply_marks(kind, predicate)
    local original = current_image(kind)
    if not original then return end
    local entries = swayimg.imagelist.get()
    for _, entry in ipairs(entries) do
        local state = predicate(entry)
        if state ~= nil and entry.mark ~= state then
            open_path(kind, entry.path)
            mark_current(kind, state)
        end
    end
    open_path(kind, original.path)
end

local function mark_range(kind)
    local image = current_image(kind)
    if not image then return end
    local anchor = mark_anchor or image.index
    local first = math.min(anchor, image.index)
    local last = math.max(anchor, image.index)
    apply_marks(kind, function(entry)
        if entry.index >= first and entry.index <= last then return true end
    end)
end

local function navigate_marked(kind, direction)
    local current = current_image(kind)
    if not current then return end
    local entries = swayimg.imagelist.get()
    for offset = 1, #entries do
        local index = ((current.index - 1 + direction * offset) % #entries) + 1
        if entries[index].mark then
            open_path(kind, entries[index].path)
            return
        end
    end
    status("No marked images")
end

local function pick_and_quit(kind)
    local entries = swayimg.imagelist.get()
    local wrote_mark = false
    for _, entry in ipairs(entries) do
        if entry.mark then
            io.write(entry.path, "\n")
            wrote_mark = true
        end
    end
    if not wrote_mark then
        local image = current_image(kind)
        if image then io.write(image.path, "\n") end
    end
    io.flush()
    swayimg.exit()
end

local function remove_current(kind)
    local image = current_image(kind)
    if image then swayimg.imagelist.remove(image.path) end
end

local function trash_selection(kind)
    local current = current_image(kind)
    if not current then return end
    local paths = {}
    for _, entry in ipairs(swayimg.imagelist.get()) do
        if entry.mark then table.insert(paths, entry.path) end
    end
    if #paths == 0 then paths = { current.path } end

    local quoted = {}
    for _, path in ipairs(paths) do table.insert(quoted, shell_quote(path)) end
    local result = os.execute("garbage put -q -- " .. table.concat(quoted, " "))
    if result == true or result == 0 then
        swayimg.imagelist.remove(paths)
        status(string.format("Moved %d image(s) to trash", #paths))
    else
        status("Trash operation failed")
    end
end

local function arm_external_prefix()
    prefix_token = prefix_token + 1
    local token = prefix_token
    status("Ctrl+x: press X to trash")
    swayimg.defer(2, function()
        if prefix_token == token then prefix_token = 0 end
    end)
end

local function run_external_x(kind)
    if prefix_token == 0 then return end
    prefix_token = 0
    trash_selection(kind)
end

local function toggle_text()
    swayimg.text.visible = not swayimg.text.visible
end

local function zoom_step(direction, at_pointer)
    local current = swayimg.viewer.scale
    local target = zoom_levels[direction > 0 and #zoom_levels or 1]
    if direction > 0 then
        for _, level in ipairs(zoom_levels) do
            if level > current + 0.0001 then
                target = level; break
            end
        end
    else
        for index = #zoom_levels, 1, -1 do
            if zoom_levels[index] < current - 0.0001 then
                target = zoom_levels[index]
                break
            end
        end
    end
    if at_pointer then
        local mouse = swayimg.get_mouse_pos()
        swayimg.viewer.set_abs_scale(target, mouse.x, mouse.y)
    else
        swayimg.viewer.set_abs_scale(target)
    end
end

local function thumb_step(direction)
    local current = swayimg.gallery.thumb_size
    local target = thumb_levels[direction > 0 and #thumb_levels or 1]
    if direction > 0 then
        for _, level in ipairs(thumb_levels) do
            if level > current then
                target = level; break
            end
        end
    else
        for index = #thumb_levels, 1, -1 do
            if thumb_levels[index] < current then
                target = thumb_levels[index]; break
            end
        end
    end
    swayimg.gallery.thumb_size = target
end

local function pan(dx, dy, page)
    local position = swayimg.viewer.get_position()
    local window = swayimg.get_window_size()
    local divisor = page and 1.0 or 15.0
    local xstep = math.max(1, math.floor(window.width / divisor))
    local ystep = math.max(1, math.floor(window.height / divisor))
    swayimg.viewer.set_abs_position(
        position.x - dx * xstep,
        position.y - dy * ystep
    )
end

local navigation_pending = false
local navigation_from = nil

-- Accept the next repeat only after a different image has actually been drawn.
swayimg.on_redrawn(function()
    if not navigation_pending then return end
    local image = swayimg.viewer.get_image()
    if image and image.path ~= navigation_from then
        navigation_pending = false
    end
end)

local function open_image(direction, top_left)
    if navigation_pending then return end
    local image = swayimg.viewer.get_image()
    navigation_from = image and image.path or nil
    navigation_pending = true
    if not swayimg.viewer.open(direction) then
        navigation_pending = false
        return
    end
    if top_left then
        swayimg.viewer.set_fix_position("center")
    end
end

local function skip_images(amount)
    local direction = amount > 0 and "next" or "prev"
    for _ = 1, math.abs(amount) do swayimg.viewer.open(direction) end
end

local function toggle_checkerboard()
    checkerboard = not checkerboard
    if checkerboard then
        swayimg.viewer.set_image_chessboard(16, 0xff3c3836, 0xff504945)
    else
        swayimg.viewer.set_image_background(colors.background)
    end
end

local function rebuild_gallery(entries, selected_index, replacement_paths)
    local paths = replacement_paths or {}
    if not replacement_paths then
        for _, entry in ipairs(entries) do table.insert(paths, entry.path) end
    end
    swayimg.imagelist.order = "none"
    swayimg.imagelist.clear()
    swayimg.imagelist.add(paths)
    for index, entry in ipairs(entries) do
        if entry.mark then
            swayimg.gallery.select_path(paths[index])
            swayimg.gallery.mark_image(true)
        end
    end
    swayimg.gallery.select_path(paths[selected_index])
end

local function move_gallery_horizontal(delta)
    local selected = swayimg.gallery.get_image()
    if not selected then return end
    local entries = swayimg.imagelist.get()
    local destination = selected.index + delta
    if destination < 1 or destination > #entries then return end
    entries[selected.index], entries[destination] = entries[destination], entries[selected.index]
    rebuild_gallery(entries, destination)
end

local function move_gallery_vertical(direction)
    local selected = swayimg.gallery.get_image()
    if not selected then return end
    local entries = swayimg.imagelist.get()
    if not swayimg.gallery.select(direction) then return end
    local destination = swayimg.gallery.get_image()
    if not destination then return end
    entries[selected.index], entries[destination.index] = entries[destination.index], entries[selected.index]
    rebuild_gallery(entries, destination.index)
end

local function ordered_targets(entries)
    if #entries == 0 then return nil end
    local directory = entries[1].path:match("^(.*)/[^/]+$")
    if not directory then return nil end
    local width = math.max(3, #tostring(#entries))
    local targets = {}
    for index, entry in ipairs(entries) do
        if entry.path:match("^(.*)/[^/]+$") ~= directory then return nil end
        local basename = entry.path:match("([^/]+)$")
        local extension = basename:match("(%.[^.]*)$") or ""
        targets[index] = string.format("%s/%0" .. width .. "d%s", directory, index, extension)
    end
    return targets
end

local function rename_ordered()
    local selected = swayimg.gallery.get_image()
    if not selected then return end
    local entries = swayimg.imagelist.get()
    local targets = ordered_targets(entries)
    if not targets then
        status("Ordered rename requires files from one directory")
        return
    end
    local args = {}
    for _, entry in ipairs(entries) do table.insert(args, shell_quote(entry.path)) end
    local helper = (os.getenv("HOME") or "") .. "/.config/swayimg/rename-ordered"
    local result = os.execute(shell_quote(helper) .. " " .. table.concat(args, " "))
    if result == true or result == 0 then
        rebuild_gallery(entries, selected.index, targets)
        status("Renamed images in displayed order")
    else
        status("Ordered rename failed; files were left unchanged")
    end
end

swayimg.viewer.on_image_change(function()
    local image = swayimg.viewer.get_image()
    if image and image.path ~= current_path then
        alternate_path = current_path
        current_path = image.path
    end
end)

-- General viewer bindings.
bind(swayimg.viewer, "q", function() swayimg.exit() end)
bind(swayimg.viewer, "Shift+q", function() pick_and_quit("viewer") end)
bind(swayimg.viewer, "Return", function() swayimg.mode = "gallery" end)
bind(swayimg.viewer, "f", function() swayimg.fullscreen = not swayimg.fullscreen end)
bind(swayimg.viewer, "Ctrl+s", toggle_text)
bind(swayimg.viewer, "Ctrl+x", arm_external_prefix)
bind(swayimg.viewer, "Shift+x", function() run_external_x("viewer") end)
bind(swayimg.viewer, "g", function() swayimg.viewer.open("first") end)
bind(swayimg.viewer, "Shift+g", function() swayimg.viewer.open("last") end)
bind(swayimg.viewer, "r", swayimg.viewer.reload)
bind(swayimg.viewer, "Shift+d", function() remove_current("viewer") end)
bind(swayimg.viewer, "m", function() toggle_mark("viewer") end)
bind(swayimg.viewer, "Shift+m", function() mark_range("viewer") end)
bind(swayimg.viewer, "Ctrl+m", function()
    apply_marks("viewer", function(entry) return not entry.mark end)
end)
bind(swayimg.viewer, "Ctrl+u", function()
    apply_marks("viewer", function() return false end)
end)
bind(swayimg.viewer, "Shift+n", function() navigate_marked("viewer", 1) end)
bind(swayimg.viewer, "Shift+p", function() navigate_marked("viewer", -1) end)

-- Viewer navigation, zoom and transforms.
bind(swayimg.viewer, "n", function() open_image("next", true) end)
bind(swayimg.viewer, "space", function() open_image("next", false) end)
bind(swayimg.viewer, "p", function() open_image("prev", true) end)
bind(swayimg.viewer, "backspace", function() open_image("prev", false) end)
bind(swayimg.viewer, "bracketright", function() skip_images(10) end)
bind(swayimg.viewer, "bracketleft", function() skip_images(-10) end)
bind(swayimg.viewer, "Ctrl+6", function()
    if alternate_path then swayimg.viewer.open_path(alternate_path) end
end)
bind(swayimg.viewer, "Ctrl+n", function()
    swayimg.viewer.frame = swayimg.viewer.frame + 1
end)
bind(swayimg.viewer, "Ctrl+p", function()
    if swayimg.viewer.frame > 0 then swayimg.viewer.frame = swayimg.viewer.frame - 1 end
end)
bind(swayimg.viewer, { "Ctrl+space", "Ctrl+a" }, function()
    swayimg.viewer.animation = not swayimg.viewer.animation
end)
bind(swayimg.viewer, { "h", "left" }, function() pan(-1, 0, false) end)
bind(swayimg.viewer, { "j", "down" }, function() pan(0, 1, false) end)
bind(swayimg.viewer, { "k", "up" }, function() pan(0, -1, false) end)
bind(swayimg.viewer, { "l", "right" }, function() pan(1, 0, false) end)
bind(swayimg.viewer, { "Ctrl+h", "Ctrl+left" }, function() pan(-1, 0, true) end)
bind(swayimg.viewer, { "Ctrl+j", "Ctrl+down" }, function() pan(0, 1, true) end)
bind(swayimg.viewer, { "Ctrl+k", "Ctrl+up" }, function() pan(0, -1, true) end)
bind(swayimg.viewer, { "Ctrl+l", "Ctrl+right" }, function() pan(1, 0, true) end)
bind(swayimg.viewer, { "equal", "KP_Add" }, function() zoom_step(1, false) end)
bind(swayimg.viewer, { "minus", "KP_Subtract" }, function() zoom_step(-1, false) end)
bind(swayimg.viewer, "z", function() swayimg.viewer.set_fix_position("center") end)
bind(swayimg.viewer, "plus", function() swayimg.viewer.set_abs_scale(1.0) end)
bind(swayimg.viewer, "w", function() swayimg.viewer.set_fix_scale("optimal") end)
bind(swayimg.viewer, "Shift+w", function() swayimg.viewer.set_fix_scale("fit") end)
bind(swayimg.viewer, "Shift+f", function() swayimg.viewer.set_fix_scale("fill") end)
bind(swayimg.viewer, "e", function() swayimg.viewer.set_fix_scale("width") end)
bind(swayimg.viewer, "Shift+e", function() swayimg.viewer.set_fix_scale("height") end)
bind(swayimg.viewer, "less", function() swayimg.viewer.rotate(270) end)
bind(swayimg.viewer, "greater", function() swayimg.viewer.rotate(90) end)
bind(swayimg.viewer, "question", function() swayimg.viewer.rotate(180) end)
bind(swayimg.viewer, "Shift+h", swayimg.viewer.flip_horizontal)
bind(swayimg.viewer, "Shift+v", swayimg.viewer.flip_vertical)
bind(swayimg.viewer, "a", function() swayimg.antialiasing = not swayimg.antialiasing end)
bind(swayimg.viewer, "Shift+a", toggle_checkerboard)
bind(swayimg.viewer, "s", function() swayimg.mode = "slideshow" end)

-- Viewer mouse behavior: thirds navigation, middle-button drag, wheel zoom.
swayimg.viewer.on_mouse("MouseLeft", function()
    local mouse = swayimg.get_mouse_pos()
    local window = swayimg.get_window_size()
    if mouse.x < window.width * 0.33 then
        swayimg.viewer.open("prev")
    elseif mouse.x > window.width * 0.67 then
        swayimg.viewer.open("next")
    end
end)
swayimg.viewer.on_mouse("MouseRight", function() swayimg.mode = "gallery" end)
swayimg.viewer.on_mouse("ScrollUp", function() zoom_step(1, true) end)
swayimg.viewer.on_mouse("ScrollDown", function() zoom_step(-1, true) end)

-- General gallery bindings.
bind(swayimg.gallery, "q", function() swayimg.exit() end)
bind(swayimg.gallery, "Shift+q", function() pick_and_quit("gallery") end)
bind(swayimg.gallery, "Return", function() swayimg.mode = "viewer" end)
bind(swayimg.gallery, "f", function() swayimg.fullscreen = not swayimg.fullscreen end)
bind(swayimg.gallery, "Ctrl+s", toggle_text)
bind(swayimg.gallery, "Ctrl+x", arm_external_prefix)
bind(swayimg.gallery, "Shift+x", function() run_external_x("gallery") end)
bind(swayimg.gallery, "g", function() swayimg.gallery.select("first") end)
bind(swayimg.gallery, "Shift+g", function() swayimg.gallery.select("last") end)
bind(swayimg.gallery, "r", swayimg.gallery.reload)
bind(swayimg.gallery, "Shift+r", swayimg.gallery.reload)
bind(swayimg.gallery, "Shift+d", function() remove_current("gallery") end)
bind(swayimg.gallery, "m", function() toggle_mark("gallery") end)
bind(swayimg.gallery, "Shift+m", function() mark_range("gallery") end)
bind(swayimg.gallery, "Ctrl+m", function()
    apply_marks("gallery", function(entry) return not entry.mark end)
end)
bind(swayimg.gallery, "Ctrl+u", function()
    apply_marks("gallery", function() return false end)
end)
bind(swayimg.gallery, "Shift+n", function() navigate_marked("gallery", 1) end)
bind(swayimg.gallery, "Shift+p", function() navigate_marked("gallery", -1) end)
bind(swayimg.gallery, { "h", "left" }, function() swayimg.gallery.select("left") end)
bind(swayimg.gallery, { "j", "down" }, function() swayimg.gallery.select("down") end)
bind(swayimg.gallery, { "k", "up" }, function() swayimg.gallery.select("up") end)
bind(swayimg.gallery, { "l", "right" }, function() swayimg.gallery.select("right") end)
bind(swayimg.gallery, { "Ctrl+j", "Ctrl+down" }, function() swayimg.gallery.select("pgdown") end)
bind(swayimg.gallery, { "Ctrl+k", "Ctrl+up" }, function() swayimg.gallery.select("pgup") end)
bind(swayimg.gallery, { "equal", "KP_Add" }, function() thumb_step(1) end)
bind(swayimg.gallery, { "minus", "KP_Subtract" }, function() thumb_step(-1) end)

-- The nsxiv-order patch, recreated using Swayimg's image-list API.
bind(swayimg.gallery, "Shift+h", function() move_gallery_horizontal(-1) end)
bind(swayimg.gallery, "Shift+j", function() move_gallery_vertical("down") end)
bind(swayimg.gallery, "Shift+k", function() move_gallery_vertical("up") end)
bind(swayimg.gallery, "Shift+l", function() move_gallery_horizontal(1) end)
bind(swayimg.gallery, "Ctrl+r", rename_ordered)

swayimg.gallery.on_mouse("MouseLeft", function()
    local mouse = swayimg.get_mouse_pos()
    swayimg.gallery.select_at(mouse.x, mouse.y)
end)
swayimg.gallery.on_mouse("MouseRight", function()
    local mouse = swayimg.get_mouse_pos()
    if swayimg.gallery.select_at(mouse.x, mouse.y) then
        swayimg.gallery.mark_image()
    else
        swayimg.gallery.mark_image()
    end
end)
swayimg.gallery.on_mouse("ScrollUp", function() swayimg.gallery.select("up") end)
swayimg.gallery.on_mouse("ScrollDown", function() swayimg.gallery.select("down") end)
swayimg.gallery.on_mouse("Ctrl+ScrollUp", function() swayimg.gallery.select("pgup") end)
swayimg.gallery.on_mouse("Ctrl+ScrollDown", function() swayimg.gallery.select("pgdown") end)

bind(swayimg.slideshow, "s", function() swayimg.mode = "viewer" end)
bind(swayimg.slideshow, "q", function() swayimg.exit() end)
