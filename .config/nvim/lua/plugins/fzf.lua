return {
    "ibhagwan/fzf-lua",
    lazy = true,
    cmd  = "FzfLua",
    keys = {
        {
            "<C-t>",
            function() require("fzf-lua").files() end,
            mode = "n"
        },
        {
            "<Leader>fz",
            function() require("fzf-lua").zoxide() end,
            mode = "n"
        },
        {
            "<Leader>fl",
            function() require("fzf-lua").blines() end,
            mode = "n"
        },
        {
            "rfv",
            function() require("fzf-lua").live_grep() end,
            mode = "n"
        },
        {
            "<Leader>ff",
            function() require("fzf-lua").files({ cwd_prompt = false, cwd = "~" }) end,
            mode = "n"
        },
        {
            "<C-x><C-f>",
            function() require("fzf-lua").complete_path({ cmd = os.getenv("FZF_DEFAULT_COMMAND") }) end,
            mode = "i"
        }
    },
    opts = function()
        local actions = require("fzf-lua").actions

        return {
            keymap        = {
                fzf = {
                    ["ctrl-u"] = "half-page-up"
                },
            },
            fzf_opts      = {
                ["--border"]         = "none",
                ["--padding"]        = "0%",
                ["--margin"]         = "0%",
                ["--no-separator"]   = "",
                ["--preview-window"] = "up,50%,noborder",
                ["--info"]           = "default",
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
                multiline = 1,
            },
            blines        = {
                rg_opts = "--line-number --colors=line:none",
            },
            winopts       = {
                title_flags = false,
                preview = {
                    border = "none",
                    default = "bat",
                    scrollbar = false,
                    vertical = "up:50%",
                    delay = 4,
                },
                border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
                height = "0.8",
                width = "0.60",
                col = 0.48,
            },
            previewers    = {
                bat = {
                    cmd  = "bat",
                    args = "--style=plain --color=always",
                },
            },
            files         = {
                file_icons  = false,
                git_icons   = false,
                color_icons = false,
                cmd         = os.getenv("FZF_DEFAULT_COMMAND")
            },
            diagnostics   = {
                multiline = false,
                signs = {
                    ["Error"] = { text = "", texthl = "DiagnosticError" },
                    ["Warn"]  = { text = "", texthl = "DiagnosticWarn" },
                    ["Info"]  = { text = "", texthl = "DiagnosticInfo" },
                    ["Hint"]  = { text = "󰌵", texthl = "DiagnosticHint" },
                },
            },
            actions       = {
                files = {
                    ["default"] = actions.file_edit_or_qf,
                    ["ctrl-x"] = actions.file_vsplit,
                    ["ctrl-s"] = actions.file_split,
                    ["ctrl-t"] = false,
                    ["alt-q"] = actions.file_sel_to_qf,
                    ["alt-l"] = actions.file_sel_to_ll,
                },
                buffers = {
                    ["default"] = actions.buf_edit,
                    ["ctrl-s"]  = actions.buf_split,
                    ["ctrl-x"]  = actions.buf_vsplit,
                    ["ctrl-t"]  = false,
                }
            }
        }
    end
}
