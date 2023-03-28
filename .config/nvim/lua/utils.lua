local M = {}

function M.kmap(modes, keys, cmd, args)
    local opts = args or { silent = true, noremap = true, }

    if vim.version().api_level >= 9 then
        vim.keymap.set(modes, keys, cmd, opts)
    else
        error("API level >= 9 requirement not fulfilled.")
    end
end

return M
