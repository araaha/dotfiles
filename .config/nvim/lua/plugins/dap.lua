return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "igorlfs/nvim-dap-view",

        -- Language-specific debuggers
        "leoluz/nvim-dap-go", -- Golang

        -- Shows variable values inline as virtual text
        "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
        {
            "<leader>dsi",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step Into",
        },
        {
            "<leader>dso",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step Out",
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle Breakpoint",
        },
        {
            "<leader>dt",
            function()
                require("dap-view").toggle()
            end,
            desc = "Debug: Toggle UI",
        },
    },
    config = function()
        local dap, dv, dg, dvt = require("dap"), require("dap-view"), require("dap-go"), require("nvim-dap-virtual-text")
        dap.listeners.before.attach["dap-view-config"] = function()
            dv.open()
        end
        dap.listeners.before.launch["dap-view-config"] = function()
            dv.open()
        end
        dap.listeners.before.event_terminated["dap-view-config"] = function()
            dv.close()
        end
        dap.listeners.before.event_exited["dap-view-config"] = function()
            dv.close()
        end
        -- Setup virtual text to show variable values inline
        dvt.setup()
        dg.setup()
    end,
}
