return {
    "ibhagwan/fzf-lua",
    branch = "trace",
    lazy   = true,
    cmd    = "FzfLua",
    keys   = { "<C-t>", " fl", " ff" },
    config = function()
        local fzf = require("fzf-lua")
        local actions = require("fzf-lua").actions

        fzf.setup({
            fzf_bin    = "fzf",
            keymap     = {
                fzf = {
                    ["ctrl-u"] = "half-page-up"
                },
            },
            fzf_opts   = {
                ["--border"]         = "none",
                ["--padding"]        = "0%",
                ["--margin"]         = "0%",
                ["--no-separator"]   = "",
                ["--preview-window"] = "up,50%,noborder",
                ["--info"]           = "default",
            },
            fzf_colors = {
                ["gutter"] = "-1",
                ["bg"] = "-1",
            },
            blines     = {
                rg_opts = "--line-number --colors=line:none",
            },
            winopts    = {
                preview = {
                    default = "bat",
                    scrollbar = false,
                    delay = 1,
                },
                win_border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
                hl = { border = "FloatBorder", },
                height = "0.8",
                width = "0.60",
                col = 0.48,
            },
            previewers = {
                bat = {
                    cmd  = "bat",
                    args = "--style=plain --color=always",
                },
            },
            files      = {
                file_icons = false,
                git_icons = false,
                color_icons = false,
                cmd = os.getenv("FZF_DEFAULT_COMMAND"),
            },
            actions    = {
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

        vim.keymap.set("n", " fl", fzf.blines, {})
        vim.keymap.set("n", " ff", function()
            fzf.files({ cwd_prompt = false, cwd = "~" })
        end, {})
        vim.keymap.set("n", "<C-t>", function()
            fzf.files({
                preview = "bat --wrap=auto --style=plain --color=always --line-range=1:25 {} ",
                actions = {
                    ["default"] = actions.file_edit_or_qf,
                    ["ctrl-x"] = actions.file_vsplit,
                    ["ctrl-s"] = actions.file_split,
                    ["ctrl-t"] = false,
                    ["alt-q"] = actions.file_sel_to_qf,
                    ["alt-l"] = actions.file_sel_to_ll,
                }
            })
        end, {})
    end,
}
