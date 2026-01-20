---@class keymap.Config
---@field default_icon? string
---@field wk_fallback? boolean
local Config = {}

Config.default_icon = ""
Config.wk_fallback = true

---@param opts? keymap.Config
function Config.setup(opts)
  opts = opts or {}
  if opts.default_icon ~= nil then
    Config.default_icon = opts.default_icon
  end
  if opts.wk_fallback ~= nil then
    Config.wk_fallback = opts.wk_fallback
  end
end

return Config
