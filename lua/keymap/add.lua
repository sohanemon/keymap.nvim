---@class keymap.AddOpts
---@field key string
---@field action? string|function
---@field mode? keymap.Mode
---@field desc? string
---@field remap? boolean
---@field buffer? boolean|number
---@field filetype? string|string[]
---@field buftype? string|string[]
---@field icon? string
---@field vscode? string

local M = {}

--- Create a key mapping with optional buffer/filetype/buftype scoping.
--- If action is nil, creates a which-key group with desc as the group name.
---@param opts keymap.AddOpts
function M.add(opts)
  local key = opts.key
  local action = opts.action
  local mode = opts.mode or "n"
  local desc = opts.desc
  local remap = opts.remap
  local buffer = opts.buffer
  local filetype = opts.filetype
  local buftype = opts.buftype
  local icon = opts.icon
  local vscode_cmd = opts.vscode

  local command = (vim.g.vscode and vscode_cmd) and function()
    require("vscode").call(vscode_cmd)
  end or action

  require("keymap.util").delete(key, mode)

  local function add_keymap(bufnr)
    local wk_status, wk = pcall(require, "which-key")
    local config = require("keymap.config")
    if wk_status and wk and wk.add then
      if command then
        wk.add({
          {
            key,
            command,
            desc = desc,
            mode = mode,
            remap = remap,
            buffer = bufnr,
            icon = icon or config.get_icon(),
          },
        })
      else
        wk.add({
          {
            key,
            group = desc,
            mode = mode,
            buffer = bufnr,
            icon = icon or config.get_group_icon(),
          },
        })
      end
    else
      vim.keymap.set(mode, key, action or command, {
        desc = desc,
        remap = remap,
        buffer = bufnr,
      })
    end
  end

  if type(filetype) == "string" then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetype,
      callback = function()
        add_keymap(true)
      end,
    })
  elseif type(filetype) == "table" then
    for _, pat in ipairs(filetype) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = pat,
        callback = function()
          add_keymap(true)
        end,
      })
    end
  elseif type(buftype) == "string" then
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.bo.buftype == buftype then
          add_keymap(true)
        end
      end,
    })
  elseif type(buftype) == "table" then
    for _, bt in ipairs(buftype) do
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if vim.bo.buftype == bt then
            add_keymap(true)
          end
        end,
      })
    end
  else
    add_keymap(buffer)
  end
end

return M.add
