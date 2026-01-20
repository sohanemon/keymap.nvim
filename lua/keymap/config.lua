---@class keymap.Config
---@field icon? string|keymap.Config.Icon

local Config = {}

Config.icon = {
  default = "",  -- Default icon for keymaps
  group = ""     -- Default icon for groups
}

---@param opts? keymap.Config
function Config.setup(opts)
  opts = opts or {}
  if opts.icon ~= nil then
    Config.icon = opts.icon
  end
end

--- Get the icon for a keymap
---@return string
function Config.get_icon()
  if type(Config.icon) == "table" then
    return Config.icon.default or ""
  else
    return Config.icon or ""
  end
end

--- Get the icon for a group
---@return string
function Config.get_group_icon()
  if type(Config.icon) == "table" then
    return Config.icon.group or Config.icon.default or ""
  else
    return Config.icon or ""
  end
end

return Config
