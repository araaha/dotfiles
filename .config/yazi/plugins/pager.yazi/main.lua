local get_hovered = ya.sync(function()
    local hovered = cx.active.current.hovered
    if not hovered then
        return nil
    end

    return {
        path = tostring(hovered.url),
        ext = hovered.url.ext and hovered.url.ext:lower() or "",
        mime = hovered:mime(),
    }
end)

local function run_pager(path)
    return Command("bat")
        :arg(path)
        :stdin(Command.INHERIT)
        :stdout(Command.INHERIT)
        :stderr(Command.INHERIT)
        :status()
end

local function render_with(renderer, args)
    local producer, producer_err = Command(renderer)
        :arg(args)
        :stdout(Command.PIPED)
        :stderr(Command.INHERIT)
        :spawn()

    if not producer then
        return nil, producer_err
    end

    local pager, pager_err = Command("bat")
        :stdin(producer:take_stdout())
        :stdout(Command.INHERIT)
        :stderr(Command.INHERIT)
        :spawn()

    if not pager then
        producer:start_kill()
        producer:wait()
        return nil, pager_err
    end

    local status, wait_err = pager:wait()
    producer:wait()

    return status, wait_err
end

local function notify_error(message)
    ya.notify {
        title = "Pager",
        content = tostring(message),
        level = "error",
        timeout = 5,
    }
end

return {
    entry = function()
        local file = get_hovered()
        if not file then
            return
        end

        -- Use Yazi's cached MIME type to ensure this is a text file.
        if not file.mime or (not file.mime:match("^text/") and not file.mime:match("json")) then
            ya.notify {
                title = "Pager",
                content = "Not a text file: " .. (file.mime or "unknown MIME type"),
                level = "warn",
                timeout = 3,
            }
            return
        end

        -- Temporarily hide Yazi and give the pager control of the terminal.
        local permit = ui.hide()
        local _, err

        if file.ext == "html" or file.ext == "htm" then
            _, err = render_with("cha", {
                "-d",
                file.path,
            })
        elseif file.ext == "md" or file.ext == "markdown" then
            _, err = render_with("mdcat", {
                "--ansi",
                file.path,
            })
        else
            _, err = run_pager(file.path)
        end

        -- Restore Yazi after quitting the pager.
        permit:drop()

        if err then
            notify_error(err)
        end
    end,
}
