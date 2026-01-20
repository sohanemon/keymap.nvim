local a = require("plenary.async.tests")
local eq = assert.are.same

a.describe("keymap.config", function()
  local config

  before_each(function()
    config = require("keymap.config")
    config.default_icon = ""
    config.wk_fallback = true
  end)

  it("should have correct default values", function()
    eq(config.default_icon, "")
    eq(config.wk_fallback, true)
  end)

  it("should override default_icon when provided", function()
    config.setup({ default_icon = "→" })
    eq(config.default_icon, "→")
  end)

  it("should override wk_fallback when provided", function()
    config.setup({ wk_fallback = false })
    eq(config.wk_fallback, false)
  end)

  it("should preserve values when opts is nil", function()
    config.default_icon = "X"
    config.wk_fallback = false
    config.setup(nil)
    eq(config.default_icon, "X")
    eq(config.wk_fallback, false)
  end)

  it("should preserve values when opts is empty", function()
    config.default_icon = "Y"
    config.wk_fallback = true
    config.setup({})
    eq(config.default_icon, "Y")
    eq(config.wk_fallback, true)
  end)

  it("should handle partial updates", function()
    config.setup({ default_icon = "★" })
    eq(config.default_icon, "★")
    eq(config.wk_fallback, true)
  end)
end)
