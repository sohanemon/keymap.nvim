local M = {
  default_icon = "",
  wk_fallback = true,
}

function M.setup(opts)
  opts = opts or {}
  M.default_icon = opts.default_icon or M.default_icon
  if opts.wk_fallback ~= nil then
    M.wk_fallback = opts.wk_fallback
  end
end

return M
