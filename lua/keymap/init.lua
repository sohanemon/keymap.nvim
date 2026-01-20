local M = {}

setmetatable(M, {
  __index = function(t, k)
    if k == "remap" then
      t[k] = require("keymap.remap").remap
    elseif k == "send_key" then
      t[k] = require("keymap.util").send_key
    elseif k == "delete_keymap" then
      t[k] = require("keymap.util").delete_keymap
    elseif k == "setup" then
      t[k] = require("keymap.config").setup
    elseif k == "config" then
      t[k] = require("keymap.config")
    elseif k == "util" then
      t[k] = require("keymap.util")
    elseif k == "remap_mod" then
      t[k] = require("keymap.remap")
    else
      t[k] = nil
    end
    return rawget(t, k)
  end,
})

_G.Keymap = M

return M
