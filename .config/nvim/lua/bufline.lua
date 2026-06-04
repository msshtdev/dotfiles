local function render()
    local s = ""
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.buflisted(buf) == 1 then
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
            if name == "" then name = "[No Name]" end
            local modified = vim.bo[buf].modified and "+" or " "
            if vim.api.nvim_get_current_buf() == buf then
                s = s .. "%#TabLineSel# " .. buf .. " " .. name .. modified .. " "
            else
                s = s .. "%#TabLine# " .. buf .. " " .. name .. modified .. " "
            end
        end
    end
    return s .. "%#TabLineFill#"
end

_G.BuflineRender = render

vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.BuflineRender()"
