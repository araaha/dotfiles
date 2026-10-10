local map = vim.keymap.set

map("n", "<M-i>", "<C-i>")
map("n", "<M-o>", "<C-o>")
map("n", "<C-i>", "")
map("n", "<C-o>", "")
map("n", "zq", "ZQ")
map("n", "zQ", "ZQ")
map("n", "Zq", "ZQ")
map("n", "zz", "ZZ")
map("i", "<C-c>", "<Esc>")
map("i", "<C-v>", "")
map("i", "<C-q>", "")
map("i", "<C-l>", "")
map("n", "<C-c>", ":noh<CR><Esc>", { silent = true })
map("n", "D", "dd")
map("n", "gJ", "J")
map({ "n", "v", "o" }, "H", "_")
map({ "n", "v", "o" }, "L", "$")
map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")
map("n", "<C-w>s", ":new<CR>", { silent = true })
map("n", "<C-w>v", ":vnew<CR>", { silent = true })
map("n", "K", ":bnext<CR>", { silent = true })
map("n", "J", ":bprev<CR>", { silent = true })
map("n", "<C-e>", ":b#<CR>", { silent = true })
map({ "n", "v" }, "<C-PageDown>", ":m .+1<CR>", { silent = true })
map({ "n", "v" }, "<C-PageUp>", ":m .-2<CR>", { silent = true })
map("n", "X", function()
    local preview = package.loaded["features.definition_preview"]
    if preview and preview.close_if_active() then return end
    vim.cmd("bdelete!")
end, { silent = true, desc = "Close definition previews or delete the buffer" })
map({ "i" }, "<C-s>", "<C-o>:silent! w<CR>", { silent = true })
map({ "n" }, "<C-s>", ":silent! w<CR>", { silent = true })

map("n", "<M-PageDown>", ":silent! cnext<CR>", { silent = true })
map("n", "<M-PageUp>", ":silent! cprevious<CR>", { silent = true })
map("n", "<PageDown>", ":silent! lnext<CR>", { silent = true })
map("n", "<PageUp>", ":silent! lprevious<CR>", { silent = true })
map("n", "i", function()
    if #vim.fn.getline(".") == 0 then
        return [["_cc]]
    else
        return "i"
    end
end, { expr = true, desc = "properly indent on empty line when insert" })

map("n", "<Leader>tr", [[:%s/\s\+$//e<CR>:w<CR>]], { silent = true })
map({ "v" }, "gs", [[y<esc>:%s/<C-r>"//g<left><left>]], {})
map("t", "<esc>", "<C-\\>", {})

map({ "n", "v" }, "<Leader>y", [["+y]], {})
map({ "n", "v" }, "<Leader>p", [["+p]], {})
map("o", "ir", "i[")
map("o", "ar", "a[")
map("o", "ia", "i<")
map("o", "aa", "a<")

map("n", "<Leader>lf", function()
    require("features.yazi").open()
end, { desc = "Choose a file with Yazi" })
map("n", "<Leader>lg", ":vert term lazygit<CR>", { silent = true })
map("n", "<Leader>lp", ":silent! Lazy profile<CR>", { silent = true })

for _, direction in ipairs({ "h", "j", "k", "l" }) do
    map({ "n", "i", "t", "v" }, "<M-" .. direction .. ">", function()
        require("features.tmux").navigate(direction)
    end, { desc = "Navigate Neovim/tmux " .. direction, silent = true })
end

map("n", "<C-a>", function()
    require("features.togglewords").toggle_word()
end, { silent = true, desc = "Toggle word or increment number" })
map("n", "<C-x>", function()
    require("features.togglewords").toggle_word_reverse()
end, { silent = true, desc = "Toggle word or decrement number" })
map("n", "<Leader>ru", function()
    require("features.runner").run()
end, { desc = "Run the current file" })
map("n", "<Leader>u", function()
    require("features.undotree").open()
end, { desc = "Open undo tree" })

map("n", "=f", function()
    local win = vim.api.nvim_get_current_win()
    if vim.fn.getqflist({ winid = 0 }).winid > 0 then
        vim.cmd("copen")
    elseif vim.fn.getloclist(win, { winid = 0 }).winid > 0 then
        vim.cmd("lopen")
    end
end, { desc = "Focus the open quickfix or location list" })

map({ "n", "x", "o" }, "<Tab>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_parent(vim.v.count1)
    else
        vim.lsp.buf.selection_range(vim.v.count1)
    end
end, { desc = "Select parent Tree-sitter node or outer LSP selection" })

map({ "n", "x", "o" }, "<S-Tab>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_child(vim.v.count1)
    else
        vim.lsp.buf.selection_range(-vim.v.count1)
    end
end, { desc = "Select child Tree-sitter node or inner LSP selection" })
