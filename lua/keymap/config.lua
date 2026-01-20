local M = {
  default_icon = "",
  wk_fallback = true,
}

function M.setup(opts)
  opts = opts or {}
  M.default_icon = opts.default_icon or M.default_icon
  M.wk_fallback = opts.wk_fallback ~= nil and opts.wk_fallback or M.wk_fallback
end

return M
