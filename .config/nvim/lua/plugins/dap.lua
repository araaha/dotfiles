return {
    "mfussenegger/nvim-dap",
    version = false,
    lazy    = true,
    config  = function()
        vim.keymap.set("n", "<Leader>dus", function()
            local widgets = require('dap.ui.widgets')
            local sidebar = widgets.sidebar(widgets.scopes)
            sidebar.open()
        end, {})
    end
}
