local uv    = vim.uv
local stamp = vim.fn.stdpath("data") .. "/mason_last_update"

local function needs_weekly_update()
  local stat = uv.fs_stat(stamp)
  if not stat then return true end
  return (os.time() - stat.mtime.sec) >= (7 * 24 * 60 * 60)
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if not needs_weekly_update() then return end
    local registry = require("mason-registry")
    registry.refresh(function()
      for _, pkg in ipairs(registry.get_installed_packages()) do
        pkg:install()
      end
      local f = io.open(stamp, "w")
      if f then f:close() end
    end)
  end,
})
