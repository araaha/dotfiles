vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('i', '<C-v>', '')
vim.keymap.set('i', '<C-q>', '')
vim.keymap.set('i', '<C-l>', '')
vim.keymap.set('i', '<C-l>', '')
vim.keymap.set({ 'n', 'i' }, '<C-h>', '<C-w>')
vim.keymap.set('n', '<C-c>', ':noh<CR><Esc>', { silent = true })
vim.keymap.set('n', 'D', 'dd')
vim.keymap.set('', '<C-h>', '<C-w>h')
vim.keymap.set('', '<C-j>', '<C-w>j')
vim.keymap.set('', '<C-k>', '<C-w>k')
vim.keymap.set('', '<C-l>', '<C-w>l')
vim.keymap.set('n', 'gt', ':bnext<CR>', { silent = true })
vim.keymap.set('n', 'gT', ':bprev<CR>', { silent = true })
vim.keymap.set('n', ' q', 'q', { silent = true })
vim.keymap.set('n', '<C-PageDown>', ':m .+1<CR>', { silent = true })
vim.keymap.set('n', '<C-PageUp>', ':m .-2<CR>', { silent = true })
vim.keymap.set('n', '<space>x', ':bdelete<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<C-s>', ':w<CR>', { silent = true, noremap = true })
vim.keymap.set({ 'i' }, '<C-s>', '<Esc>:w<CR>i', { silent = true, noremap = true })


vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "{", "{(zz")
vim.keymap.set({ "n", "v" }, "}", "})zz")
vim.keymap.set("n", "<C-o>", "<C-o>zz")
vim.keymap.set("n", "<C-i>", "<C-i>zz")
vim.keymap.set("n", "<C-i>", "<C-i>zz")

local toggle_ll = function()
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.loclist == 1 then
            vim.cmd("lclose")
            return
        end
    end
    if next(vim.fn.getloclist(0)) == nil then
        vim.diagnostic.setloclist()
        return
    end
    vim.diagnostic.setloclist()
    vim.cmd("lopen")
end

local toggle_ql = function()
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    if vim.fn.getqflist() == 0 then
        vim.diagnostic.setqflist()
        return
    end
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end

vim.keymap.set('n', ' ll', function() toggle_ll() end, {})
vim.keymap.set('n', ' lf', ':silent! lopen<CR>', { silent = true })
vim.keymap.set('n', ' lp', ':silent! Lazy profile<CR>', { silent = true })
vim.keymap.set('n', ' ql', function() toggle_ql() end, {})
vim.keymap.set('n', ' qf', ':silent! copen<CR>', { silent = true })
vim.keymap.set('n', '<M-PageDown>', ':silent! cnext<CR>', { silent = true })
vim.keymap.set('n', '<M-PageUp>', ':silent! cprevious<CR>', { silent = true })
vim.keymap.set('n', '<PageDown>', ':silent! lnext<CR>', { silent = true })
vim.keymap.set('n', '<PageUp>', ':silent! lprevious<CR>', { silent = true })
vim.keymap.set("n", "i", function()
    if #vim.fn.getline(".") == 0 then
        return [["_cc]]
    else
        return "i"
    end
end, { expr = true, desc = "properly indent on empty line when insert" })



vim.keymap.set('n', '<CR>', function()
    if vim.o.buftype == "quickfix" then
        return "<CR>"
    else
        return 'moo<Esc>`o:delm o<CR>'
    end
end, { expr = true, replace_keycodes = true })

vim.keymap.set('n', '<S-CR>', function()
    if vim.o.buftype == "quickfix" then
        return "<CR>"
    else
        return 'mpO<Esc>`p:delm p<CR>'
    end
end, { expr = true, replace_keycodes = true })
