local ts = { cmd = { "typescript-language-server", "--stdio" }, roots = { "package.json", ".git" } }

local servers = {
    go         = { cmd = { "gopls" },                         roots = { "go.mod", "go.work" } },
    python     = { cmd = { "pyright-langserver", "--stdio" }, roots = { "pyproject.toml", "setup.py", ".git" } },
    terraform  = { cmd = { "terraform-ls", "serve" },        roots = { ".terraform", "*.tf" } },
    javascript = ts,
    typescript = ts,
}

vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("lsp", { clear = true }),
    pattern  = vim.tbl_keys(servers),
    callback = function()
        local s = servers[vim.bo.filetype]
        vim.lsp.start({
            name     = s.cmd[1],
            cmd      = s.cmd,
            root_dir = vim.fs.dirname(
                vim.fs.find(s.roots, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]
            ),
        })
        vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
})
