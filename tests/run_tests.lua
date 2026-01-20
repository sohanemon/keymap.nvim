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
  end)

  it("should have correct default values", function()
    assert(config.default_icon == "", "default_icon should be ")
  end)

  it("should override default_icon when provided", function()
    config.setup({ default_icon = "→" })
    assert(config.default_icon == "→", "default_icon should be →")
  end)

  it("should preserve values when opts is nil", function()
    config.default_icon = "X"
    config.setup(nil)
    assert(config.default_icon == "X", "default_icon should be X")
  end)

  it("should handle partial updates", function()
    config.setup({ default_icon = "★" })
    assert(config.default_icon == "★", "default_icon should be ★")
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

  it("should call vim.keymap.del in delete", function()
    local del_called = false
    local del_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.del = function(mode, key)
      del_called = true
      del_args = { mode, key }
    end

    util.delete("<leader>f", "n")
    assert(del_called == true, "keymap.del should be called")
    assert(del_args[1] == "n", "mode should be n")
    assert(del_args[2] == "<leader>f", "key should be <leader>f")
  end)

  it("should use default mode 'n' in delete when mode is nil", function()
    local del_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.del = function(mode, key)
      del_args = { mode, key }
    end

    util.delete("<leader>x")
    assert(del_args[1] == "n", "default mode should be n")
  end)
end)

-- ============================================
-- ADD SUBMODULE TESTS
-- ============================================
describe("keymap.add (submodule)", function()
  local add = require("keymap.add")
  local config = require("keymap.config")

  before_each(function()
    config.default_icon = ""

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function() end
    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end
    package.loaded["which-key"] = nil
  end)

  it("should delete existing keymap before creating new one", function()
    local delete_called = false
    local util = require("keymap.util")
    util.delete = function()
      delete_called = true
    end

    add({
      key = "<leader>t",
      action = ":Test<CR>",
    })

    assert(delete_called == true, "delete should be called")
  end)

  it("should use default mode 'n' when mode is not provided", function()
    local set_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    add({
      key = "<leader>f",
      action = ":Files<CR>",
    })

    assert(set_args[1] == "n", "mode should be n")
  end)

  it("should use custom mode when provided as string", function()
    local set_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    add({
      key = "<leader>x",
      action = ":X<CR>",
      mode = "v",
    })

    assert(set_args[1] == "v", "mode should be v")
  end)

  it("should use custom mode when provided as table", function()
    local set_args = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    add({
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

    add({
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

    add({
      key = "<leader>q",
      action = ":q<CR>",
      buffer = true,
    })

    assert(set_opts.buffer == true, "buffer should be true")
  end)

  it("should pass remap option to keymap.set", function()
    local set_opts = {}

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      set_opts = opts
    end

    add({
      key = "<leader>r",
      action = ":Rebind<CR>",
      remap = true,
    })

    assert(set_opts.remap == true, "remap should be true")
  end)

  it("should handle filetype as string", function()
    local autocmd_created = false

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function(event, opts)
      if event == "FileType" and opts.pattern == "python" then
        autocmd_created = true
      end
    end

    add({
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

    add({
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

    add({
      key = "<leader>s",
      action = ":Save<CR>",
      desc = "Save",
      buftype = "nofile",
    })

    assert(autocmd_created == true, "BufEnter autocmd should be created")
  end)

  it("should handle buftype as table", function()
    local autocmd_count = 0

    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = function(event, opts)
      if event == "BufEnter" then
        autocmd_count = autocmd_count + 1
      end
    end

    add({
      key = "<leader>w",
      action = ":Write<CR>",
      desc = "Write",
      buftype = { "quickfix", "terminal" },
    })

    assert(autocmd_count == 2, "should create autocmd for each buftype")
  end)

  it("should use config.default_icon when icon is not provided", function()
    local wk_called = false
    local wk_icon = nil

    package.loaded["which-key"] = {
      add = function(args)
        wk_called = true
        wk_icon = args[1].icon
      end,
    }

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end

    add({
      key = "<leader>g",
      action = ":Go<CR>",
      desc = "Go to",
    })

    assert(wk_called == true, "which-key.add should be called")
    assert(wk_icon == "", "should use default_icon from config")
  end)

  it("should use custom icon when provided", function()
    local wk_called = false
    local wk_icon = nil

    package.loaded["which-key"] = {
      add = function(args)
        wk_called = true
        wk_icon = args[1].icon
      end,
    }

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end

    add({
      key = "<leader>h",
      action = ":Help<CR>",
      desc = "Help",
      icon = "",
    })

    assert(wk_called == true, "which-key.add should be called")
    assert(wk_icon == "", "should use custom icon")
  end)

  it("should pass remap option to which-key", function()
    local wk_opts = nil

    package.loaded["which-key"] = {
      add = function(args)
        wk_opts = args[1]
      end,
    }

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end

    add({
      key = "<leader>m",
      action = ":Map<CR>",
      desc = "Map",
      remap = true,
    })

    assert(wk_opts.remap == true, "remap should be passed to which-key")
  end)

  it("should use function action", function()
    local func_received = false

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function(mode, key, cmd, opts)
      if type(cmd) == "function" then
        func_received = true
      end
    end

    -- Clear which-key so function actions go to keymap.set
    package.loaded["which-key"] = nil

    add({
      key = "<leader>p",
      action = function()
        return "test"
      end,
      desc = "Function action",
    })

    assert(func_received == true, "function action should be passed to keymap.set")
  end)

  it("should fall back to vim.keymap.set when which-key not available", function()
    local keymap_set_called = false

    package.loaded["which-key"] = nil

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function()
      keymap_set_called = true
    end

    add({
      key = "<leader>t",
      action = ":Test<CR>",
      desc = "Test",
    })

    assert(keymap_set_called == true, "should fall back to vim.keymap.set")
  end)

  it("should use which-key when available", function()
    local wk_called = false

    package.loaded["which-key"] = {
      add = function()
        wk_called = true
      end,
    }

    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = function() end

    add({
      key = "<leader>k",
      action = ":Test<CR>",
      desc = "Test",
    })

    assert(wk_called == true, "should use which-key when available")
  end)
end)

-- ============================================
-- MAIN MODULE TESTS
-- ============================================
describe("keymap (main module)", function()
  it("should expose add function", function()
    local keymap = require("keymap")
    assert(type(keymap.add) == "function", "keymap.add should be a function")
  end)

  it("should expose send_key function", function()
    local keymap = require("keymap")
    assert(type(keymap.send_key) == "function", "keymap.send_key should be a function")
  end)

  it("should expose delete function", function()
    local keymap = require("keymap")
    assert(type(keymap.delete) == "function", "keymap.delete should be a function")
  end)

  it("should expose setup function", function()
    local keymap = require("keymap")
    assert(type(keymap.setup) == "function", "keymap.setup should be a function")
  end)

  it("should expose config table", function()
    local keymap = require("keymap")
    assert(type(keymap.config) == "table", "keymap.config should be a table")
    assert(type(keymap.config.default_icon) == "string", "config should have default_icon")
  end)

  it("should expose util table", function()
    local keymap = require("keymap")
    assert(type(keymap.util) == "table", "keymap.util should be a table")
    assert(type(keymap.util.delete) == "function", "util should have delete")
    assert(type(keymap.util.send_key) == "function", "util should have send_key")
  end)
end)

-- ============================================
-- GLOBAL KEYMAP TESTS
-- ============================================
describe("Global Keymap", function()
  it("should expose Keymap global table", function()
    assert(_G.Keymap ~= nil, "Keymap should be a global table")
    assert(type(_G.Keymap.add) == "function", "Keymap.add should be a function")
    assert(type(_G.Keymap.setup) == "function", "Keymap.setup should be a function")
    assert(type(_G.Keymap.send_key) == "function", "Keymap.send_key should be a function")
    assert(type(_G.Keymap.delete) == "function", "Keymap.delete should be a function")
  end)

  it("should have same functions as module", function()
    local keymap = require("keymap")
    assert(_G.Keymap.add == keymap.add, "Keymap.add should equal require('keymap').add")
    assert(_G.Keymap.setup == keymap.setup, "Keymap.setup should equal require('keymap').setup")
    assert(_G.Keymap.send_key == keymap.send_key, "Keymap.send_key should equal require('keymap').send_key")
    assert(_G.Keymap.delete == keymap.delete, "Keymap.delete should equal require('keymap').delete")
  end)

  it("should have same config as module", function()
    local keymap = require("keymap")
    assert(_G.Keymap.config == keymap.config, "Keymap.config should equal require('keymap').config")
  end)

  it("should have same util as module", function()
    local keymap = require("keymap")
    assert(_G.Keymap.util == keymap.util, "Keymap.util should equal require('keymap').util")
  end)
end)

-- ============================================
-- LAZY LOADING TESTS
-- ============================================
describe("Lazy loading", function()
  it("should lazy load add submodule", function()
    package.loaded["keymap.add"] = nil
    local keymap = require("keymap")
    -- Access add for the first time
    local add_fn = keymap.add
    -- Should now be cached
    assert(keymap.add == add_fn, "add should be cached after first access")
  end)

  it("should lazy load util submodule", function()
    package.loaded["keymap.util"] = nil
    local keymap = require("keymap")
    -- Access util for the first time
    local util_tbl = keymap.util
    -- Should now be cached
    assert(keymap.util == util_tbl, "util should be cached after first access")
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
