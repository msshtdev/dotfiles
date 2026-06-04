vim.api.nvim_create_autocmd("BufWritePost", {
    pattern  = { "*.c", "*.h", "*.cpp", "*.hpp", "*.go", "*.py" },
    callback = function()
        vim.fn.jobstart("ctags -R .", { detach = true })
    end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern  = "grep",
    callback = function() vim.cmd("copen") end,
})
