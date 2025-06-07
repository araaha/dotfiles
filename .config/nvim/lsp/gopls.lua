return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.mod", "go.work", ".git" },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = true
                },
            },
        },
    },
    settings = {
        gopls = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            }
        },
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
    }
}
