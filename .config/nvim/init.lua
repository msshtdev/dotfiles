-- Single source of truth: every portable setting lives in ~/.vimrc, which is
-- sourced verbatim below. Only genuinely nvim-only pieces stay in Lua, so the
-- two configs cannot drift apart.
vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
source ~/.vimrc
]])

require("keymaps")
require("lsp")
