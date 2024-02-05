local map = vim.keymap.set

map('i', '<C-c>', '<Esc>')
map('i', '<C-v>', '')
map('i', '<C-q>', '')
map('i', '<C-l>', '')
map('i', '<C-l>', '')
map({ 'n', 'i' }, '<C-h>', '<C-w>')
map('n', '<C-c>', ':noh<CR><Esc>', { silent = true })
map('n', 'D', 'dd')
map({ 'n', 'v' }, 'H', '_')
map({ 'n', 'v' }, 'L', '$')
map({ 'n', 'v' }, 'M', 'D')
map('', 'j', 'gjzz')
map('', 'k', 'gkzz')
map('n', 'G', 'Gzz')
map('n', 'gg', 'ggzz')
map('', '<C-h>', '<C-w>h')
map('', '<C-j>', '<C-w>j')
map('', '<C-k>', '<C-w>k')
map('', '<C-l>', '<C-w>l')
map('n', 'gt', ':bnext<CR>zz', { silent = true })
map('n', 'gT', ':bprev<CR>zz', { silent = true })
map('n', ' q', 'q', { silent = true })
map('n', '<C-PageDown>', ':m .+1<CR>zz', { silent = true })
map('n', '<C-PageUp>', ':m .-2<CR>zz', { silent = true })
map('n', 'X', ':bdelete!<CR>zz', { silent = true })
map({ 'i' }, '<C-s>', '<C-o>:silent! w', { silent = true })
map({ 'n' }, '<C-s>', ':silent! w<CR>', { silent = true })

map("", "n", "nzz")
map("", "N", "Nzz")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map({ "n", "v" }, "{", "{(zz")
map({ "n", "v" }, "}", "})zz")
map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")
map({ "n", "o" }, "u", "u:echo 'undo'<CR>", { silent = true })
map({ "n", "o" }, "<C-r>", "<C-r>:echo 'redo'<CR>", { silent = true })

map('n', '=l', function()
    local win = vim.api.nvim_get_current_win()
    local qf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
    local action = qf_winid > 0 and 'lclose' or 'silent! lopen'
    vim.cmd(action)
end, { silent = true })

map('n', '=q', function()
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    local action = qf_winid > 0 and 'cclose' or 'copen'
    vim.cmd(action)
end, { silent = true })

map('n', '=f', function()
    local win = vim.api.nvim_get_current_win()
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    local lf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
    if qf_winid > 0 then
        vim.cmd("copen")
    elseif lf_winid > 0 then
        vim.cmd("lopen")
    else
        return
    end
end)

map('n', ' lp', ':silent! Lazy profile<CR>', { silent = true })
map('n', '<M-PageDown>', ':silent! cnext<CR>', { silent = true })
map('n', '<M-PageUp>', ':silent! cprevious<CR>', { silent = true })
map('n', '<PageDown>', ':silent! lnext<CR>', { silent = true })
map('n', '<PageUp>', ':silent! lprevious<CR>', { silent = true })
map('n', 'i', function()
    if #vim.fn.getline(".") == 0 then
        return [["_cc]]
    else
        return "i"
    end
end, { expr = true, desc = "properly indent on empty line when insert" })

map('n', '<CR>', function()
    if vim.o.buftype == "quickfix" then
        return "<CR>"
    else
        return 'moo<Esc>`o:delm o<CR>'
    end
end, { expr = true, replace_keycodes = true })

map('n', '<S-CR>', function()
    if vim.o.buftype == "quickfix" then
        return "<CR>"
    else
        return 'mpO<Esc>`p:delm p<CR>'
    end
end, { expr = true, replace_keycodes = true })
