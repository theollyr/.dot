local M = {}

function M.on_yank()
    vim.highlight.on_yank({
        higroup = "IncSearch",
        timeout = 300,
    })
end

return M
