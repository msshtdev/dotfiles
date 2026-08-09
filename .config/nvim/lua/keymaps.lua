-- nvim-only keymaps. Everything portable lives in ~/.vimrc.

-- Diagnostics
vim.keymap.set("n", "<Leader>ld", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Terminal mode
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { noremap = true })

-- netrw sidebar. The width is a command range, not an argument: ":Lexplore 20"
-- parses the 20 as a directory name and opens at the default width instead.
vim.keymap.set("n", "<Leader>le", ":20Lexplore<CR>", { noremap = true, silent = true })
