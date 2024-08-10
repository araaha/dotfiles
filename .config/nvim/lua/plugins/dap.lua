return {
    "mfussenegger/nvim-dap",
    version = false,
    lazy    = true,
    keys    = {
        {
            "<Leader>dus",
            function()
                local widgets = require('dap.ui.widgets')
                local sidebar = widgets.sidebar(widgets.scopes)
                sidebar.toggle()
            end,
            mode = "n"
        }
    },
}
