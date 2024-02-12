return {
    "chrisgrieser/nvim-spider",
    keys = {
        {
            "w",
            "<cmd>lua require('spider').motion('w', { subwordMovement = false })<CR>",
            mode = { 'n', 'o', 'x' },
        },
        {
            "e",
            "<cmd>lua require('spider').motion('e', { subwordMovement = false })<CR>",
            mode = { 'n', 'o', 'x' },
        },
        {
            "b",
            "<cmd>lua require('spider').motion('b', { subwordMovement = false })<CR>",
            mode = { 'n', 'o', 'x' },
        },
    },
}
