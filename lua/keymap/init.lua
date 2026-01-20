local M = {}

M.remap = require("keymap.remap").remap
M.send_key = require("keymap.util").send_key
M.delete_keymap = require("keymap.util").delete_keymap
M.setup = require("keymap.config").setup

return M
