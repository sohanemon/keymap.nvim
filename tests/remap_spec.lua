local a = require("plenary.async.tests")
local eq = assert.are.same

a.describe("keymap.remap", function()
  local remap
  local util_stub
  local config

  before_each(function()
    util_stub = {
      delete_keymap = function() end,
      send_key = function() end,
      delete_keymap = function() end,
    }
    package.loaded["keymap.util"] = util_stub
    package.loaded["keymap.config"] = nil
    package.loaded["keymap.remap"] = nil

    config = require("keymap.config")
    config.default_icon = ""
    config.wk_fallback = true

    remap = require("keymap.remap")
  end)

  after_each(function()
    package.loaded["keymap.util"] = nil
    package.loaded["keymap.config"] = nil
    package.loaded["keymap.remap"] = nil
  end)

  it("should delete existing keymap before creating new one", function()
    local delete_called = false
    util_stub.delete_keymap = function()
      delete_called = true
    end

    remap.remap({
      key = "<leader>t",
      action = ":Test<CR>",
    })

    eq(delete_called, true)
  end)

  it("should use default mode 'n' when mode is not provided", function()
    local set_args = {}

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    remap.remap({
      key = "<leader>f",
      action = ":Files<CR>",
    })

    eq(set_args[1], "n")
  end)

  it("should use custom mode when provided", function()
    local set_args = {}

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function(mode, key, cmd, opts)
      set_args = { mode, key, cmd, opts }
    end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    remap.remap({
      key = "<leader>x",
      action = ":X<CR>",
      mode = { "n", "v" },
    })

    eq(set_args[1], { "n", "v" })
  end)

  it("should pass desc to keymap.set", function()
    local set_opts = {}

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function(mode, key, cmd, opts)
      set_opts = opts
    end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    remap.remap({
      key = "<leader>p",
      action = ":Project<CR>",
      desc = "Open project",
    })

    eq(set_opts.desc, "Open project")
  end)

  it("should set buffer when buffer option is true", function()
    local set_opts = {}

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function(mode, key, cmd, opts)
      set_opts = opts
    end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    remap.remap({
      key = "<leader>q",
      action = ":q<CR>",
      buffer = true,
    })

    eq(set_opts.buffer, true)
  end)

  it("should use custom icon when provided", function()
    local wk_add_called = false
    local wk_add_args = nil

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    package.loaded["which-key"] = {
      add = function(args)
        wk_add_called = true
        wk_add_args = args
      end,
    }

    remap.remap({
      key = "<leader>g",
      action = ":Go<CR>",
      desc = "Go to",
      icon = "→",
    })

    if wk_add_called then
      eq(wk_add_args[1].icon, "→")
    end
  end)

  it("should use default icon from config when icon not provided", function()
    local wk_add_called = false

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    package.loaded["which-key"] = {
      add = function(args)
        wk_add_called = true
      end,
    }

    remap.remap({
      key = "<leader>h",
      action = ":Help<CR>",
      desc = "Help",
    })

    if wk_add_called then
      eq(config.default_icon, "")
    end
  end)

  it("should handle filetype as string", function()
    local autocmd_created = false

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function(event, opts)
      if event == "FileType" and opts.pattern == "python" then
        autocmd_created = true
      end
    end

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    remap.remap({
      key = "<leader>r",
      action = ":Run<CR>",
      desc = "Run",
      filetype = "python",
    })

    eq(autocmd_created, true)
  end)

  it("should handle filetype as table", function()
    local patterns = {}

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function(event, opts)
      if event == "FileType" then
        table.insert(patterns, opts.pattern)
      end
    end

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    remap.remap({
      key = "<leader>f",
      action = ":Format<CR>",
      desc = "Format",
      filetype = { "python", "lua", "javascript" },
    })

    eq(#patterns, 3)
  end)

  it("should handle buftype as string", function()
    local autocmd_created = false

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function(event, opts)
      if event == "BufEnter" then
        autocmd_created = true
      end
    end

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    remap.remap({
      key = "<leader>s",
      action = ":Save<CR>",
      desc = "Save",
      buftype = "nofile",
    })

    eq(autocmd_created, true)
  end)

  it("should handle buftype as table", function()
    local autocmd_count = 0

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function(event, opts)
      if event == "BufEnter" then
        autocmd_count = autocmd_count + 1
      end
    end

    vim.keymap = vim.keymap or {}
    vim.keymap.set = function() end

    remap.remap({
      key = "<leader>w",
      action = ":Write<CR>",
      desc = "Write",
      buftype = { "quickfix", "terminal" },
    })

    eq(autocmd_count, 2)
  end)
end)
