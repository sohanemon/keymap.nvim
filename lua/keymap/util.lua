local M = {}

function M.delete_keymap(key, mode)
  pcall(vim.keymap.del, mode, key)
end

function M.send_key(key, mode)
  local keys = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(keys, mode or "n", false)
end

return M
