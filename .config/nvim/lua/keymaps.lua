-- Buffer navigation
vim.keymap.set("n", "<Leader>b", ":buffers<CR>:buffer<Space>", { noremap = true })
vim.keymap.set("n", "<Leader>n", ":bn<CR>",                    { noremap = true })
vim.keymap.set("n", "<Leader>p", ":bp<CR>",                    { noremap = true })
vim.keymap.set("n", "<Leader>d", ":bd<CR>",                    { noremap = true })

for i = 1, 9 do
    vim.keymap.set("n", "<Leader>" .. i, ":" .. i .. "b<CR>", { noremap = true, silent = true })
end

-- Save & Exit
vim.keymap.set("n", "<Leader>w", ":wa<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "ZZ", ":qa!<CR>", { noremap = true, silent = true })

-- Resolve vim's 'path' to concrete directories for rg.
-- Skips wildcards (**) and absolute system paths (/usr/include etc.).
local function search_dirs()
    local dirs, seen = {}, {}
    for _, p in ipairs(vim.opt.path:get()) do
        local d = (p == "" or p == ".") and "." or p
        if not d:match("%*") and not d:match("^/") and not seen[d] then
            seen[d] = true
            table.insert(dirs, vim.fn.shellescape(d))
        end
    end
    return #dirs > 0 and dirs or { "." }
end

-- Search
vim.keymap.set("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true })

local function vgrep()
    local args = vim.fn.input("grep> ")
    if args == "" then return end

    local dirs = table.concat(search_dirs(), " ")
    local cmd  = string.format("rg --vimgrep --smart-case %s %s 2>/dev/null | head -n 1000", args, dirs)
    local output = vim.fn.systemlist(cmd)

    if #output == 0 then
        vim.notify("grep: no matches found", vim.log.levels.INFO)
        return
    end

    if #output >= 1000 then
        vim.notify("grep: too many results, showing first 1000", vim.log.levels.WARN)
    end

    local items = {}
    for _, line in ipairs(output) do
        local file, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
        if file then
            table.insert(items, { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = text })
        end
    end

    vim.fn.setqflist({}, "r", { title = "grep", items = items })
    vim.cmd("copen")
end
vim.keymap.set("n", "<Leader>g", vgrep, { noremap = true, silent = true })

-- Ripgrep file finder → quickfix  (single call, glob-based)
-- Usage: [rg-opts] glob-pattern   (last word = pattern, rest = rg --files options)
--   "foo"              → rg --files --glob "*foo*" <path-dirs>
--   "*.md"             → rg --files --glob "*.md"  <path-dirs>
--   "-uu *.md"         → rg --files -uu --glob "*.md" <path-dirs>
--   "--type py foo"    → rg --files --type py --glob "*foo*" <path-dirs>
local function vfind()
    local input = vim.fn.input("vfind> ")
    if input == "" then return end

    local parts   = vim.split(vim.trim(input), "%s+")
    local pattern = table.remove(parts)
    local rg_args = table.concat(parts, " ")

    local glob = pattern:match("[%*%?%[]") and pattern or ("*" .. pattern .. "*")
    local dirs = table.concat(search_dirs(), " ")
    local cmd  = string.format("rg --files %s --glob %s %s 2>/dev/null | head -n 1000", rg_args, vim.fn.shellescape(glob), dirs)
    local output = vim.fn.systemlist(cmd)

    if #output == 0 then
        vim.notify("vfind: no files found", vim.log.levels.INFO)
        return
    end

    if #output >= 1000 then
        vim.notify("vfind: too many results, showing first 1000", vim.log.levels.WARN)
    end

    local items = {}
    for _, f in ipairs(output) do
        table.insert(items, { filename = f, lnum = 1, col = 1, text = f })
    end

    vim.fn.setqflist({}, "r", { title = "vfind", items = items })
    vim.cmd("copen")
end

vim.keymap.set("n", "<Leader>f", vfind, { noremap = true, silent = true })

-- In the quickfix window: <CR> opens the file.
-- If the list was populated by vfind, also remove that entry from the list.
vim.api.nvim_create_autocmd("FileType", {
    pattern  = "qf",
    callback = function()
        vim.keymap.set("n", "<CR>", function()
            local idx  = vim.fn.line(".")
            local info = vim.fn.getqflist({ title = 1 })

            if info.title == "vfind" then
                local qflist = vim.fn.getqflist()
                local item   = qflist[idx]
                table.remove(qflist, idx)
                vim.fn.setqflist({}, "r", { title = "vfind", items = qflist })

                if item and item.bufnr > 0 then
                    vim.cmd("wincmd p")
                    vim.cmd("buffer " .. item.bufnr)
                    vim.bo.buflisted = true
                end

                vim.cmd("cclose")
            else
                vim.cmd("cc " .. idx)
		vim.cmd("cclose")
            end
        end, { buffer = true, noremap = true, silent = true })
    end,
})

-- Surround visual selection
vim.keymap.set("v", "(", "<ESC>`>a)<ESC>`<i(<ESC>", { noremap = true })
vim.keymap.set("v", "[", "<ESC>`>a]<ESC>`<i[<ESC>", { noremap = true })
vim.keymap.set("v", "{", "<ESC>`>a}<ESC>`<i{<ESC>", { noremap = true })
vim.keymap.set("v", "``", "<ESC>`>a`<ESC>`<i`<ESC>", { noremap = true })
vim.keymap.set("v", "''", "<ESC>`>a'<ESC>`<i'<ESC>", { noremap = true })
vim.keymap.set("v", "\"\"", "<ESC>`>a\"<ESC>`<i\"<ESC>", { noremap = true })

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

-- Quick Reference to the current file directory
vim.keymap.set("n", "<Leader>e", ":e <C-r>=expand('%:h').'/'<CR>", { noremap = true })

-- LSP omni-completion
vim.keymap.set("i", "<C-n>", "<C-x><C-o>", { noremap = true })
