#!/usr/bin/env lua
-- Standalone test runner (no plenary dependency)

-- Add lua directory to package path
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

local tests_passed = 0
local tests_failed = 0
local current_describe = ""

function describe(name, fn)
  current_describe = name
  print("\n[DESCRIBE] " .. name)
  fn()
end

function it(name, fn)
  if _G.before_each_fn then
    _G.before_each_fn()
  end
  local success, err = pcall(fn)
  if success then
    print("  [PASS] " .. name)
    tests_passed = tests_passed + 1
  else
    print("  [FAIL] " .. name .. ": " .. tostring(err))
    tests_failed = tests_failed + 1
  end
  if _G.after_each_fn then
    _G.after_each_fn()
  end
end

function before_each(fn)
  _G.before_each_fn = fn
end

function after_each(fn)
  _G.after_each_fn = fn
end

function setup_test_environment()
  _G.vim = _G.vim or {}
  _G.vim.g = _G.vim.g or {}
  _G.vim.bo = _G.vim.bo or {}
  _G.vim.wo = _G.vim.wo or {}
  _G.vim.opt = _G.vim.opt or {}
  _G.vim.api = _G.vim.api or {}
  _G.vim.keymap = _G.vim.keymap or {}
end

setup_test_environment()

-- Load the plugin to set up global Keymap
dofile("plugin/keymap.lua")

print("========================================")
print("keymap.nvim - Standalone Test Suite")
print("========================================")

-- ============================================
-- CONFIG TESTS
-- ============================================
describe("keymap.config", function()
  local config = require("keymap.config")

  before_each(function()
    config.default_icon = ""
    config.wk_fallback = true
  end)

  it("should have correct default values", function()
    assert(config.default_icon == "", "default_icon should be ")
    assert(config.wk_fallback == true, "wk_fallback should be true")
  end)

  it("should override default_icon when provided", function()
    config.setup({ default_icon = "→" })
    assert(config.default_icon == "→", "default_icon should be →")
  end)

  it("should override wk_fallback when provided", function()
    config.setup({ wk_fallback = false })
    assert(config.wk_fallback == false, "wk_fallback should be false")
  end)

  it("should preserve values when opts is nil", function()
    config.default_icon = "X"
    config.wk_fallback = false
    config.setup(nil)
    assert(config.default_icon == "X", "default_icon should be X")
    assert(config.wk_fallback == false, "wk_fallback should be false")
  end)

  it("should handle partial updates", function()
    config.setup({ default_icon = "★" })
    assert(config.default_icon == "★", "default_icon should be ★")
    assert(config.wk_fallback == true, "wk_fallback should still be true")
  end)
end)

-- ============================================
-- UTIL TESTS
-- ============================================
describe("keymap.util", function()
  local util = require("keymap.util")

  it("should call nvim_replace_termcodes in send_key", function()
    local replaced = false
    local feedkeys_called = false

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_replace_termcodes = function(key, _, _, _)
      replaced = true
      return key
    end
    _G.vim.api.nvim_feedkeys = function(keys, mode, _)
      feedkeys_called = true
      assert(keys == "<Esc>", "should send <Esc>")
      assert(mode == "i", "should use mode i")
    end

    util.send_key("<Esc>", "i")
    assert(replaced == true, "replace_termcodes should be called")
    assert(feedkeys_called == true, "feedkeys should be called")
  end)

  it("should use default mode 'n' when mode is nil", function()
    local feedkeys_mode = nil

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_replace_termcodes = function(key, _, _, _)
      return key
    end
    _G.vim.api.nvim_feedkeys = function(_, mode, _)
      feedkeys_mode = mode
    end

    util.send_key("<Esc>")
    assert(feedkeys_mode == "n", "default mode should be n")
  end)

  it("should call vim.keymap.del in delete_keymap", function()
    local del_called = false
    local del_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.del = function(mode, key)
      del_called = true
      del_args = { mode, key }
    end

    util.delete_keymap("<leader>f", "n")
    assert(del_called == true, "keymap.del should be called")
    assert(del_args[1] == "n", "mode should be n")
    assert(del_args[2] == "<leader>f", "key should be <leader>f")
  end)
end)

-- ============================================
-- REMAP TESTS
-- ============================================
describe("keymap.remap", function()
  local remap = require("keymap.remap")
  local config = require("keymap.config")

  before_each(function()
    config.default_icon = ""
    config.wk_fallback = true

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function() end
    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end
  end)

  it("should delete existing keymap before creating new one", function()
    local delete_called = false
    local util = require("keymap.util")
    util.delete_keymap = function()
      delete_called = true
    end
    package.loaded["keymap.remap"] = nil
    remap = require("keymap.remap")

    remap.remap({
      key = "<leader>t",
      action = ":Test<CR>",
    })

    assert(delete_called == true, "delete_keymap should be called")
  end)

  it("should use default mode 'n' when mode is not provided", function()
    local set_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    remap.remap({
      key = "<leader>f",
      action = ":Files<CR>",
    })

    assert(set_args[1] == "n", "mode should be n")
  end)

  it("should use custom mode when provided", function()
    local set_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    remap.remap({
      key = "<leader>x",
      action = ":X<CR>",
      mode = { "n", "v" },
    })

    assert(set_args[1][1] == "n", "mode[1] should be n")
    assert(set_args[1][2] == "v", "mode[2] should be v")
  end)

  it("should pass desc to keymap.set", function()
    local set_opts = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_opts = opts
    end

    remap.remap({
      key = "<leader>p",
      action = ":Project<CR>",
      desc = "Open project",
    })

    assert(set_opts.desc == "Open project", "desc should be passed")
  end)

  it("should set buffer when buffer option is true", function()
    local set_opts = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_opts = opts
    end

    remap.remap({
      key = "<leader>q",
      action = ":q<CR>",
      buffer = true,
    })

    assert(set_opts.buffer == true, "buffer should be true")
  end)

  it("should handle filetype as string", function()
    local autocmd_created = false

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function(event, opts)
      if event == "FileType" and opts.pattern == "python" then
        autocmd_created = true
      end
    end

    remap.remap({
      key = "<leader>r",
      action = ":Run<CR>",
      desc = "Run",
      filetype = "python",
    })

    assert(autocmd_created == true, "FileType autocmd should be created")
  end)

  it("should handle filetype as table", function()
    local patterns = {}

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function(event, opts)
      if event == "FileType" then
        table.insert(patterns, opts.pattern)
      end
    end

    remap.remap({
      key = "<leader>f",
      action = ":Format<CR>",
      desc = "Format",
      filetype = { "python", "lua", "javascript" },
    })

    assert(#patterns == 3, "should create autocmd for each filetype")
  end)

  it("should handle buftype as string", function()
    local autocmd_created = false

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function(event, opts)
      if event == "BufEnter" then
        autocmd_created = true
      end
    end

    remap.remap({
      key = "<leader>s",
      action = ":Save<CR>",
      desc = "Save",
      buftype = "nofile",
    })

    assert(autocmd_created == true, "BufEnter autocmd should be created")
  end)
end)

-- ============================================
-- GLOBAL KEYMAP TESTS
-- ============================================
describe("Global Keymap", function()
  it("should expose Keymap global table", function()
    assert(_G.Keymap ~= nil, "Keymap should be a global table")
    assert(type(_G.Keymap.remap) == "function", "Keymap.remap should be a function")
    assert(type(_G.Keymap.setup) == "function", "Keymap.setup should be a function")
    assert(type(_G.Keymap.send_key) == "function", "Keymap.send_key should be a function")
    assert(type(_G.Keymap.delete_keymap) == "function", "Keymap.delete_keymap should be a function")
  end)

  it("should have same functions as module", function()
    local keymap = require("keymap")
    assert(_G.Keymap.remap == keymap.remap, "Keymap.remap should equal require('keymap').remap")
    assert(_G.Keymap.setup == keymap.setup, "Keymap.setup should equal require('keymap').setup")
    assert(_G.Keymap.send_key == keymap.send_key, "Keymap.send_key should equal require('keymap').send_key")
    assert(_G.Keymap.delete_keymap == keymap.delete_keymap, "Keymap.delete_keymap should equal require('keymap').delete_keymap")
  end)
end)

-- ============================================
-- SUMMARY
-- ============================================
print("\n========================================")
print("Test Summary")
print("========================================")
print("Passed: " .. tests_passed)
print("Failed: " .. tests_failed)
print("Total:  " .. (tests_passed + tests_failed))
print("========================================")

if tests_failed > 0 then
  os.exit(1)
else
  print("All tests passed!")
  os.exit(0)
end
