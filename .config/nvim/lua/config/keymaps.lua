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
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map('', '<C-h>', '<C-w>h')
map('', '<C-j>', '<C-w>j')
map('', '<C-k>', '<C-w>k')
map('', '<C-l>', '<C-w>l')
map('n', 'gt', ':bnext<CR>', { silent = true })
map('n', 'gT', ':bprev<CR>', { silent = true })
map('n', ' q', 'q', { silent = true })
map('n', '<C-PageDown>', ':m .+1<CR>', { silent = true })
map('n', '<C-PageUp>', ':m .-2<CR>', { silent = true })
map('n', '<space>x', ':bdelete!<CR>', { silent = true })
map({ 'i' }, '<C-s>', '<C-o>:silent! w<CR>', { silent = true })
map({ 'n' }, '<C-s>', ':silent! w<CR>', { silent = true })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map({ "n", "v" }, "{", "{(zz")
map({ "n", "v" }, "}", "})zz")
map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")
map("n", "u", "u:echo 'undo'<CR>", { silent = true })
map("n", "<C-r>", "<C-r>:echo 'redo'<CR>", { silent = true })


local toggle_ll = function()
    if next(vim.fn.getloclist(0)) == nil then
        vim.diagnostic.setloclist()
        return
    end
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.loclist == 1 then
            vim.cmd("lclose")
            return
        end
    end
    vim.diagnostic.setloclist()
    vim.cmd("lopen")
end

local toggle_ql = function()
    if vim.fn.getqflist() == 0 then
        vim.diagnostic.setqflist()
        return
    end
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end

map('n', ' ll', function() toggle_ll() end, {})
map('n', ' lf', ':silent! lopen<CR>', { silent = true })
map('n', ' lp', ':silent! Lazy profile<CR>', { silent = true })
map('n', ' ql', function() toggle_ql() end, {})
map('n', ' qf', ':silent! copen<CR>', { silent = true })
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
