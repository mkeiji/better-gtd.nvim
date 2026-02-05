local M = {}

if vim.fn.has("nvim-0.10") == 1 then
    M.impl = require("better-gtd.modern")
else
    M.impl = require("better-gtd.legacy")
end

M.setup = function()
    M.impl.setup()
end

return M
