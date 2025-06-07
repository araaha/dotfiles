return {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
        {
            "<Leader>gf",
            "<cmd>GrugFar<cr>",
            mode = "n"
        }
    },
    opts = {
        wrap = false,
        icons = {
            enabled = false
        },
        showCompactInputs = false,
        showInputsTopPadding = false,
        showInputsBottomPadding = false,
        showStatusIcon = false,
        showEngineInfo = false,
        showStatusInfo = false
    }
}
