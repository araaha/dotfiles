return {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git", "ty.toml" },
    settings = {
        ty = {
            completions = {
                completeFunctionParentheses = true,
            },
        },
    },
}
