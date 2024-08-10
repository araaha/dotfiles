return {
    "ibhagwan/fzf-lua",
    branch = "trace",
    lazy   = true,
    cmd    = "FzfLua",
    keys   = { "<C-t>", "<Leader>fl", "<Leader>ff", { "<C-x><C-f>", mode = "i" } },
    config = function()
        local fzf = require("fzf-lua")
        local actions = require("fzf-lua").actions

        fzf.setup({
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
                ["bg"] = "-1",
            },
            hls           = {
                path_linenr = "GruvboxGreen",
                buf_name = "FloatBorder"
            },
            complete_file = {
                cmd = os.getenv("FZF_DEFAULT_COMMAND")
            },
            grep          = {
                multiline = 1,
            },
            blines        = {
                rg_opts = "--line-number --colors=line:none",
            },
            winopts       = {
                preview = {
                    default = "bat",
                    scrollbar = false,
                    delay = 4,
                },
                win_border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
                hl = { border = "FloatBorder", },
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
            },
        })

        vim.keymap.set("n", "<C-t>", fzf.files, {})
        vim.keymap.set("i", "<C-x><C-f>", fzf.complete_file, { silent = true })
        vim.keymap.set("n", "<Leader>fl", fzf.blines, {})
        vim.keymap.set("n", "<Leader>ff", function()
            fzf.files({ cwd_prompt = false, cwd = "~" })
        end, {})
    end,
}
