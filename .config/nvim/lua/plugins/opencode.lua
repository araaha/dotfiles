return {
    "sudo-tee/opencode.nvim",
    keys = {
        {
            "<leader>ot",
            function() require("opencode.api").toggle() end,
            mode = "n"
        },
    },
    opts = {},
    dependencies = {
        -- {
        --     "MeanderingProgrammer/render-markdown.nvim",
        --     opts = {
        --         anti_conceal = { enabled = false },
        --         file_types = { 'markdown', 'opencode_output' },
        --     },
        --     ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
        -- },
        -- Optional, for file mentions and commands completion, pick only one
        'saghen/blink.cmp',

        -- Optional, for file mentions picker, pick only one
        'ibhagwan/fzf-lua',
    },
}
