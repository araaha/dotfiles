---@diagnostic disable: undefined-global
local function setup(_, options)
    options = options or {}

    local default_separators = {
        angly = { "", "", "", "" },
        curvy = { "", "", "", "" },
        liney = { "", "", "|", "|" },
        empty = { "", "", "", "" },
    }
    local separators = default_separators[options.separator_style or "empty"]

    local config = {
        separator_open = options.separator_open or separators[1],
        separator_close = options.separator_close or separators[2],
        separator_open_thin = options.separator_open_thin or separators[3],
        separator_close_thin = options.separator_close_thin or separators[4],
        background = options.background or "black",
        mode_normal = options.mode_normal or "cyan",
        mode_select = options.mode_select or "magenta",
        mode_unset = options.mode_unset or "red",
        percent = options.percent or "green",
        position = options.position or "cyan",
        select_symbol = options.select_symbol or "S",
        yank_symbol = options.yank_symbol or "Y",
        default_files_color = options.default_files_color or "darkgray",
        selected_files_color = options.selected_files_color or "white",
        yanked_files_color = options.yanked_files_color or "green",
        cut_files_color = options.cut_files_color or "red",
        filename_max_length = options.filename_max_length or 24,
        filename_truncate_length = options.filename_truncate_length or 6,
        filename_truncate_separator = options.filename_truncate_separator or "...",
    }

    local mode_colors = {
        normal = config.mode_normal,
        select = config.mode_select,
        unset = config.mode_unset,
    }

    function Status:mode()
        local mode = tostring(self._tab.mode)
        local color = mode_colors[mode] or config.mode_normal

        return ui.Line {
            ui.Span(config.separator_open):fg(color),
            ui.Span(" " .. mode:upper() .. " ")
                :fg(config.background)
                :bg(color),
        }
    end

    function Status:length()
        local hovered = self._current.hovered
        local length = hovered and hovered.cha.len or 0

        return ""
    end

    function Status:utf8_sub(str, start_char, end_char)
        local start_byte = utf8.offset(str, start_char)
        local end_byte = end_char and (utf8.offset(str, end_char + 1) - 1) or #str
        if not start_byte or not end_byte then
            return ""
        end
        return string.sub(str, start_byte, end_byte)
    end

    function Status:truncate_name(filename, max_length)
        local base_name, extension = filename:match("^(.+)(%.[^%.]+)$")
        base_name = base_name or filename
        extension = extension or ""

        if utf8.len(base_name) > max_length then
            base_name = self:utf8_sub(base_name, 1, config.filename_truncate_length)
                .. config.filename_truncate_separator
                .. self:utf8_sub(base_name, -config.filename_truncate_length)
        end
        return base_name .. extension
    end

    function Status:name()
        local hovered = self._current.hovered
        local name = hovered
            and self:truncate_name(hovered.name, config.filename_max_length)
            or "Empty dir"

        return ui.Line {
            ui.Span(config.separator_close .. " ")
                :fg(config.mode_normal)
                :bg(config.background),
            ui.Span(name .. " ")
                :fg(config.mode_normal)
                :bg(config.background),
        }
    end

    function Status:files()
        -- local yanked = #cx.yanked
        -- local selected = #cx.active.selected
        -- local selected_color = selected > 0
        --     and config.selected_files_color
        --     or config.default_files_color
        -- local yanked_color = yanked > 0
        --     and (cx.yanked.is_cut and config.cut_files_color or config.yanked_files_color)
        --     or config.default_files_color
        --
        -- return ui.Line {
        --     ui.Span(" " .. config.separator_close_thin .. " ")
        --         :fg(config.default_files_color)
        --         :bg(config.background),
        --     ui.Span(string.format("%s %d ", config.select_symbol, selected))
        --         :fg(selected_color)
        --         :bg(config.background),
        --     ui.Span(string.format("%s %d  ", config.yank_symbol, yanked))
        --         :fg(yanked_color)
        --         :bg(config.background),
        -- }
    end

    function Status:percent()
        return ""
    end

    function Status:position()
        local cursor = self._tab.current.cursor
        local length = #self._tab.current.files
        local position = math.min(cursor + 1, length)

        return ui.Line {
            ui.Span(config.separator_open):fg(config.position),
            ui.Span(string.format("" .. " %d/%d ", position, length))
                :fg(config.background)
                :bg(config.position),
        }
    end

    function Header:cwd()
        local user = ya.user_name() or os.getenv("USER") or "user"
        local host = ya.host_name() or "host"
        local cwd = tostring(cx.active.current.cwd)
        local home = os.getenv("HOME")

        if home and cwd:sub(1, #home) == home then
            cwd = "~" .. cwd:sub(#home + 1)
        end

        return ui.Line({
            ui.Span(user .. "@" .. host .. ":"):fg("green"):bold(),
            ui.Span(cwd):fg("blue"):bold(),
        })
    end

    local old_permissions = Status.permissions

    function Status:permissions()
        return ui.Line({
            old_permissions(self),
            ui.Span(" "),
        })
    end

    -- Preserve all built-in status children; only append the S/Y counter.
    Status:children_add(Status.files, 4000, Status.LEFT)
end

return { setup = setup }
