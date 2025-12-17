require("fzf-lua").setup({
    { "cli" },
    fzf_opts      = {
        ["--height"]         = "70%",
        ["--border"]         = "bold",
        ["--padding"]        = "0%",
        ["--margin"]         = "0%",
        ["--no-separator"]   = "",
        ["--preview-window"] = "up,50%,noborder",
        ["--info"]           = "default",
        ["--tmux"]           = false,
    },
    fzf_colors    = {
        ["gutter"] = "-1",
        ["bg"]     = "-1",
    },
    hls           = {
        live_prompt = "Normal",
        path_linenr = "GruvboxGreen",
        buf_name = "FloatBorder",
        border = "FloatBorder"
    },
    complete_file = {
        cmd = os.getenv("FZF_DEFAULT_COMMAND"),
    },
    grep          = {
        winopts = {
            title = "",
            preview = {
                layout = "vertical",
                border = "none",
                scrollbar = false,
                delay = 4,
            },
        },
        actions = {
            ["enter"] = function(selected)
                if not selected or not selected[1] then return end

                local entry = selected[1]
                local file, row, col = entry:match("^(.-):(%d+):(%d+)")
                if not file then return end

                local cmd = string.format(
                    "nvim +%s %s",
                    vim.fn.shellescape(string.format("call cursor(%d,%d)", tonumber(row), tonumber(col))),
                    vim.fn.shellescape(file)
                )
                os.execute(cmd)
            end,
        },


        cmd =
        "RIPGREP_CONFIG_PATH=/home/araaha/.config/ripgreprc rg --column --color=always",
    },
    blines        = {
        rg_opts = "--line-number --colors=line:none",
    },
    winopts       = {
        title = "",
        title_flags = false,
        preview = {
            title = false,
            border = "none",
            default = "bat",
            scrollbar = false,
            vertical = "up:50%",
            delay = 4,
        },
    },
    previewers    = {
        bat = {
            cmd  = "bat",
            args = "--style=plain --color=always",
        },
    },
    files         = {
        winopts     = {
            title = "",
            title_flags = false,
            preview = {
                title = false,
                border = "none",
                default = "bat",
                scrollbar = false,
                vertical = "up:50%",
                delay = 4,
            },
        },
        actions     = {
            ["enter"] = function(selected)
                if not selected or not selected[1] then return end

                local editor = "nvim"

                os.execute(editor .. " " .. vim.fn.shellescape(selected[1]))
            end,
        },
        file_icons  = false,
        git_icons   = false,
        color_icons = false,
        cmd         = os.getenv("FZF_DEFAULT_COMMAND")
    },
})
