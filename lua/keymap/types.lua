---@class KeymapOpts
---@field key string The key sequence to map from (required)
---@field action string|function The target key/command or function (required)
---@field buffer? boolean|number Buffer-local mapping (true for current buffer, or specify buffer number)
---@field filetype? string|string[] Filetype pattern(s) for autocmd
---@field buftype? string|string[] Buftype pattern(s) for autocmd
---@field mode? string|string[] Mode (e.g. "n", "i", {"n", "i"}; default "n")
---@field desc? string Description for which-key
---@field remap? boolean Whether to allow remapping
---@field icon? string Icon for which-key display
---@field vscode? string VSCode command for VSCode mode

---@class KeymapConfig
---@field default_icon? string Default icon for which-key display
---@field wk_fallback? boolean Fallback to vim.keymap.set when which-key not available

return {}
