---@class keymap.Util
local M = {}

--- Delete a keymap.
---@param key string
---@param mode? string
function M.delete(key, mode)
  pcall(vim.keymap.del, mode or "n", key)
end

--- Send a key sequence to Vim.
---@param key string
---@param mode? string
function M.send_key(key, mode)
  local keys = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(keys, mode or "n", false)
end

return M
