local a = require("plenary.async.tests")
local eq = assert.are.same

a.describe("keymap.util", function()
  local util

  before_each(function()
    util = require("keymap.util")
  end)

  describe("send_key", function()
    it("should call nvim_replace_termcodes", function()
      local replaced = false
      local feedkeys_called = false

      vim.api = vim.api or {}
      vim.api.nvim_replace_termcodes = function(key, _, _, _)
        replaced = true
        return key
      end
      vim.api.nvim_feedkeys = function(keys, mode, _)
        feedkeys_called = true
        eq(keys, "<Esc>")
        eq(mode, "i")
      end

      util.send_key("<Esc>", "i")
      eq(replaced, true)
      eq(feedkeys_called, true)
    end)

    it("should use default mode 'n' when mode is nil", function()
      local feedkeys_mode = nil

      vim.api = vim.api or {}
      vim.api.nvim_replace_termcodes = function(key, _, _, _)
        return key
      end
      vim.api.nvim_feedkeys = function(_, mode, _)
        feedkeys_mode = mode
      end

      util.send_key("<Esc>")
      eq(feedkeys_mode, "n")
    end)
  end)

  describe("delete_keymap", function()
    it("should call vim.keymap.del with correct args", function()
      local del_called = false
      local del_args = {}

      vim.keymap = vim.keymap or {}
      vim.keymap.del = function(mode, key)
        del_called = true
        del_args = { mode, key }
      end

      util.delete_keymap("<leader>f", "n")
      eq(del_called, true)
      eq(del_args[1], "n")
      eq(del_args[2], "<leader>f")
    end)

    it("should handle pcall failure gracefully", function()
      local ok, _ = pcall(function()
        vim.keymap = vim.keymap or {}
        vim.keymap.del = function()
          error("keymap not found")
        end
        util.delete_keymap("<nonexistent>", "n")
      end)
      eq(ok, true)
    end)
  end)
end)
