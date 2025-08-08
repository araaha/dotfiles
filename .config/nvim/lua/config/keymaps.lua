local map = vim.keymap.set

map("n", "<M-i>", "<C-i>")
map("n", "<M-o>", "<C-o>")
map("n", "zq", "ZQ")
map("n", "zQ", "ZQ")
map("n", "Zq", "ZQ")
map("n", "zz", "ZZ")
map("i", "<C-c>", "<Esc>")
map("i", "<C-v>", "")
map("i", "<C-q>", "")
map("i", "<C-l>", "")
map("i", "<C-l>", "")
map("n", "<C-c>", ":noh<CR><Esc>", { silent = true })
map("n", "D", "dd")
map("n", "gJ", "J")
map({ "n", "v", "o" }, "H", "_")
map({ "n", "v", "o" }, "L", "$")
map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")
map("n", "<C-w>s", ":new<CR>")
map("n", "<C-w>v", ":vnew<CR>")
map("n", "K", ":bnext<CR>", { silent = true })
map("n", "J", ":bprev<CR>", { silent = true })
map({ "n", "v" }, "<C-PageDown>", ":m .+1<CR>", { silent = true })
map({ "n", "v" }, "<C-PageUp>", ":m .-2<CR>", { silent = true })
map("n", "X", ":bdelete!<CR>", { silent = true })
map({ "i" }, "<C-s>", "<C-o>:silent! w<CR>", { silent = true })
map({ "n" }, "<C-s>", ":silent! w<CR>", { silent = true })

map("n", "<Leader>lf", ":vert term lf %<CR>", { silent = true })
map("n", "<Leader>lg", ":vert term lazygit<CR>", { silent = true })
map("n", "<Leader>lp", ":silent! Lazy profile<CR>", { silent = true })

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
