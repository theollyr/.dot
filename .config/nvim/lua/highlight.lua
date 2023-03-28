return {
    on_yank = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 300,
        })
    end
}
