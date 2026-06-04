-- Buffer navigation
vim.keymap.set("n", "<Leader>b", ":buffers<CR>:buffer<Space>", { noremap = true })
vim.keymap.set("n", "<Leader>n", ":bn<CR>",                    { noremap = true })
vim.keymap.set("n", "<Leader>p", ":bp<CR>",                    { noremap = true })
vim.keymap.set("n", "<Leader>d", ":bd<CR>",                    { noremap = true })

for i = 1, 9 do
    vim.keymap.set("n", "<Leader>" .. i, ":" .. i .. "b<CR>", { noremap = true, silent = true })
end

-- Save
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true })

-- Search
vim.keymap.set("n", "<Leader>g", ":silent grep!<Space>", { noremap = true })
vim.keymap.set("n", "<Leader>f", ":find<Space>",          { noremap = true })
vim.keymap.set("n", "<Esc>",     ":noh<CR>",              { noremap = true, silent = true })

-- Surround visual selection
vim.keymap.set("v", "(", "<ESC>`>a)<ESC>`<i(<ESC>", { noremap = true })
vim.keymap.set("v", "[", "<ESC>`>a]<ESC>`<i[<ESC>", { noremap = true })
vim.keymap.set("v", "{", "<ESC>`>a}<ESC>`<i{<ESC>", { noremap = true })
vim.keymap.set("v", "<", "<ESC>`>a><ESC>`<i<<ESC>", { noremap = true })
vim.keymap.set("v", "`", "<ESC>`>a`<ESC>`<i`<ESC>", { noremap = true })
vim.keymap.set("v", "'", "<ESC>`>a'<ESC>`<i'<ESC>", { noremap = true })
vim.keymap.set("v", "\"", "<ESC>`>a\"<ESC>`<i\"<ESC>", { noremap = true })

-- gi: jump to last insert position (mark I) and resume insert
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern  = "*",
    callback = function() vim.cmd("normal! mI") end,
})

local function goto_last_insert()
    local ok = pcall(function()
        vim.cmd("normal! `I")
        vim.cmd("startinsert!")
    end)
    if not ok then
        vim.notify("No insert mark found", vim.log.levels.INFO)
    end
end
vim.keymap.set("n", "gi", goto_last_insert, { noremap = true, silent = true })

-- LSP omni-completion
vim.keymap.set("i", "<C-p>", "<C-x><C-o>", { noremap = true })
