---@class keymap.Config.Icon
---@field default? string -- Icon for keymaps
---@field group? string -- Icon for groups

---@class keymap.Config
---@field icon? string|keymap.Config.Icon

---@alias keymap.Mode
---| "n"   -- Normal
---| "v"   -- Visual
---| "x"   -- Visual (block)
---| "s"   -- Select
---| "i"   -- Insert
---| "t"   -- Terminal
---| "o"   -- Operator-pending
---| "c"   -- Command-line
---| string -- Single mode character
---| keymap.Mode[] -- Array of mode characters

---@class keymap.AddOpts
---@field key string
---@field action? string|function -- Omit to create a which-key group with desc as group name
---@field mode? keymap.Mode
---@field desc? string
---@field remap? boolean
---@field buffer? boolean|number
---@field filetype? string|string[]
---@field buftype? string|string[]
---@field icon? string
---@field vscode? string

---@class keymap.Util
---@field delete fun(key: string, mode?: keymap.Mode): nil
---@field send_key fun(key: string, mode?: keymap.Mode): nil

return {}
