---@class keymap.Config
---@field default_icon? string
---@field wk_fallback? boolean

---@class keymap.AddOpts
---@field key string
---@field action string|function
---@field mode? string|string[]
---@field desc? string
---@field remap? boolean
---@field buffer? boolean|number
---@field filetype? string|string[]
---@field buftype? string|string[]
---@field icon? string
---@field vscode? string

---@class keymap.Util
---@field delete fun(key: string, mode?: string): nil
---@field send_key fun(key: string, mode?: string): nil

return {}
