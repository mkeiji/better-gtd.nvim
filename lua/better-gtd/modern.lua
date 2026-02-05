-- better-gtd
-- support for neovim v0.11.0+
local M = {}

-- Helper function to get the current buffer's file name
local function current_buffer_fname()
    return vim.api.nvim_buf_get_name(0)
end

-- Function to open a vertical split and jump to the location if no split exists
local function open_split_if_needed_and_jump(item, target_fname)
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
        vim.api.nvim_win_set_cursor(target_win, { item.lnum, item.col })
        return
    end

    -- Otherwise, try to reuse an existing vertical split
    local split_found = false
    for _, win in ipairs(windows) do
        if win ~= current_win then
            local win_width = vim.api.nvim_win_get_width(win)
            if win_width < vim.o.columns then
                vim.api.nvim_set_current_win(win)
                split_found = true
                break
            end
        end
    end

    -- If no suitable split, create one
    if not split_found then
        vim.cmd("vsplit")
    end

    vim.cmd("edit " .. vim.fn.fnameescape(target_fname))
    vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
end

-- Main function to bind to a key like `gd`
M.go_to_definition = function()
    vim.lsp.buf.definition({
        on_list = function(opts)
            local items = opts.items
            if not items or #items == 0 then
                vim.notify("No definition found", vim.log.levels.WARN)
                return
            end

            local item = items[1]
            local target_fname = item.filename

            if target_fname == current_buffer_fname() then
                vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
            else
                open_split_if_needed_and_jump(item, target_fname)
            end
        end
    })
end

-- Setup function to bind the keymap (optional)
M.setup = function()
    vim.keymap.set("n", "gd", M.go_to_definition, { desc = "Better GTD: go to definition" })
end

return M
