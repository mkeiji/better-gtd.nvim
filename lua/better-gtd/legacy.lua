-- better-gtd
-- support for neovim v0.9.0+
local M = {}

-- Helper function to get the current buffer's file name
local function current_buffer_fname()
    return vim.api.nvim_buf_get_name(0)
end

-- Custom function to handle the LSP jump with proper offset encoding
local function jump_to_location(location, client_id)
    local client = vim.lsp.get_client_by_id(client_id)
    if client then
        -- Use the correct offset encoding
        vim.lsp.util.jump_to_location(location, client.offset_encoding)
    else
        -- Fallback in case no client is found
        vim.lsp.util.jump_to_location(location)
    end
end

-- Function to open a vertical split and jump to the location if no split exists
local function open_split_if_needed_and_jump(target_location, target_fname, client_id)
    local current_win = vim.api.nvim_get_current_win()
    local windows = vim.api.nvim_list_wins()
    local target_win = nil

    -- Check if the target file is already open in any split
    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname == target_fname then
            target_win = win
            break
        end
    end

    -- If the target file is open in an existing split, navigate to that split
    if target_win then
        vim.api.nvim_set_current_win(target_win)
        jump_to_location(target_location, client_id)
        return
    end

    -- Otherwise, create a new split if necessary
    local split_found = false
    for _, win in ipairs(windows) do
        if win ~= current_win then
            local win_width = vim.api.nvim_win_get_width(win)
            if win_width < vim.o.columns then
                vim.api.nvim_set_current_win(win) -- Use the existing vertical split
                split_found = true
                break
            end
        end
    end

    -- If no vertical split is found, create one
    if not split_found then
        vim.cmd("vsplit") -- Open a new vertical split
    end

    -- Open the target file in the split
    vim.cmd("edit " .. vim.fn.fnameescape(target_fname))
    jump_to_location(target_location, client_id)
end

-- Custom handler for LSP 'go-to-definition'
M.go_to_definition = function(_, result, ctx)
    if not result or vim.tbl_isempty(result) then
        vim.notify("Go to definition: No result from LSP", vim.log.levels.WARN)
        return
    end

    -- Some LSP servers may return multiple definitions; we use the first one.
    local target_location = result[1]

    -- Handle both 'Location' and 'LocationLink'
    local target_uri = target_location.uri or target_location.targetUri
    if not target_uri then
        vim.notify("Go to definition: Missing URI or targetUri in LSP result", vim.log.levels.ERROR)
        return
    end

    local target_fname = vim.uri_to_fname(target_uri)

    -- Check if the definition is within the same file
    if target_fname == current_buffer_fname() then
        -- Jump to the position within the same file using the correct offset encoding
        jump_to_location(target_location, ctx.client_id)
        return
    end

    -- Open the definition in a vertical split, checking for existing splits first
    open_split_if_needed_and_jump(target_location, target_fname, ctx.client_id)
end

-- Setup the plugin to override the LSP handler for 'go-to-definition'
M.setup = function()
    vim.lsp.handlers["textDocument/definition"] = M.go_to_definition
end

return M
