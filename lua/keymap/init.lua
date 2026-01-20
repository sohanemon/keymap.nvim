---@class Keymap
---@field add fun(opts: Keymap.AddOpts): nil
---@field send_key fun(key: string, mode?: string): nil
---@field delete fun(key: string, mode?: string): nil
---@field setup fun(opts?: Keymap.Config): nil
---@field config Keymap.Config
---@field util Keymap.Util
---@field version string
local M = {}

setmetatable(M, {
  __index = function(t, k)
    if k == "add" then
      t[k] = require("keymap.add")
    elseif k == "send_key" then
      t[k] = require("keymap.util").send_key
    elseif k == "delete" then
      t[k] = require("keymap.util").delete
    elseif k == "setup" then
      t[k] = require("keymap.config").setup
    elseif k == "config" then
      t[k] = require("keymap.config")
    elseif k == "util" then
      t[k] = require("keymap.util")
    end
    return rawget(t, k)
  end,
})

_G.Keymap = M

M.version = "1.0.0"

return M
