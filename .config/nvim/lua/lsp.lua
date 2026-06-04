local configs = {
    go = {
        name     = "gopls",
        cmd      = { "gopls" },
        root_dir = vim.fs.dirname(
            vim.fs.find({ "go.mod", "go.work" }, { upward = true })[1]
        ),
    },
    python = {
        name     = "pyright",
        cmd      = { "pyright-langserver", "--stdio" },
        root_dir = vim.fs.dirname(
            vim.fs.find({ "pyproject.toml", "setup.py", ".git" }, { upward = true })[1]
        ),
    },
    terraform = {
        name     = "terraform-ls",
        cmd      = { "terraform-ls", "serve" },
        root_dir = vim.fs.dirname(
            vim.fs.find({ ".terraform", "*.tf" }, { upward = true })[1]
        ),
    },
    javascript = {
        name     = "ts-language-server",
        cmd      = { "typescript-language-server", "--stdio" },
        root_dir = vim.fs.dirname(
            vim.fs.find({ "package.json", ".git" }, { upward = true })[1]
        ),
    },
    typescript = {
        name     = "ts-language-server",
        cmd      = { "typescript-language-server", "--stdio" },
        root_dir = vim.fs.dirname(
            vim.fs.find({ "package.json", ".git" }, { upward = true })[1]
        ),
    },
}

vim.api.nvim_create_autocmd("FileType", {
    pattern  = vim.tbl_keys(configs),
    callback = function()
        local cfg = configs[vim.bo.filetype]
        if cfg then
            vim.lsp.start(cfg)
            vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
        end
    end,
})
