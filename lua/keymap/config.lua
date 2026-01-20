---@class keymap.Config
---@field default_icon? string
local Config = {}

Config.default_icon = ""

---@param opts? keymap.Config
function Config.setup(opts)
  opts = opts or {}
  if opts.default_icon ~= nil then
    Config.default_icon = opts.default_icon
  end
end

return Config
