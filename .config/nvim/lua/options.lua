vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.hidden         = true
vim.opt.tabstop        = 8
vim.opt.shiftwidth     = 4
vim.opt.softtabstop    = 4
vim.opt.expandtab      = false
vim.opt.path:append("**")
vim.opt.wildoptions    = "fuzzy"

vim.opt.grepprg    = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.termguicolors = true
vim.cmd("colorscheme desert")
vim.api.nvim_set_hl(0, "Normal",      { ctermbg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "LineNr",      { ctermbg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn",  { ctermbg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { ctermbg = "NONE", bg = "NONE" })
