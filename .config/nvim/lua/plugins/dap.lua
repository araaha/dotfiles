return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "igorlfs/nvim-dap-view",

        -- Language-specific debuggers
        "leoluz/nvim-dap-go", -- Golang
    },
    keys = {
        {
            "<PageDown>",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step Into",
        },
        {
            "<PageUp>",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step Out",
        },
        {
            "<End>",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step Over",
        },
        {
            "<leader>de",
            function()
                require("dap").terminate()
                vim.opt_local.signcolumn = "no"
            end,
        },
        {
            "<leader>dc",
            function()
                require("dap").continue()
            end,
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
                vim.opt_local.signcolumn = "yes"
            end,
            desc = "Debug: Toggle Breakpoint",
        },
        {
            "<leader>dt",
            function()
                if vim.api.nvim_get_option_value("signcolumn", { scope = "local" }) == "yes" then
                    vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local" })
                else
                    vim.api.nvim_set_option_value("signcolumn", "yes", { scope = "local" })
                end
                require("dap-view").toggle()
            end,
            desc = "Debug: Toggle UI",
        },
    },
    config = function()
        local dap, dv, dg = require("dap"), require("dap-view"), require("dap-go")
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

        dap.adapters.codelldb = {
            type = "executable",
            command = "codelldb",
        }
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
            },
        }

        dv.setup({
            winbar = {
                show = true,
                -- You can add a "console" section to merge the terminal with the other views
                sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
                -- Must be one of the sections declared above
                default_section = "scopes",
            },
            windows = {
                height = math.floor(vim.o.lines * 0.33),
                position = "below",
                terminal = {
                    position = "right",
                    width = 0.3,
                    -- List of debug adapters for which the terminal should be ALWAYS hidden
                    hide = {},
                    -- Hide the terminal when starting a new session
                    start_hidden = false,
                },
            },
            help = {
                border = nil,
            },
            -- Controls how to jump when selecting a breakpoint or navigating the stack
            switchbuf = "usetab,newtab",

        })
        dg.setup()

        vim.fn.sign_define("DapBreakpoint",
            { text = "", texthl = "DapBreakpoint" })
        vim.fn.sign_define("DapStopped",
            { text = "󰐊", texthl = "DapStopped" })

        vim.opt_local.signcolumn = "yes"
    end,
}
