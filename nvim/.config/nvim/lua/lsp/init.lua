-- lua/lsp/init.lua
vim.opt.updatetime = 250
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

for _, name in ipairs(require("servers")) do
  local ok, server_opts = pcall(require, "lsp." .. name)
  if not ok then
    vim.notify("LSP config error for " .. name .. ": " .. server_opts, vim.log.levels.WARN)
  elseif type(server_opts) == "table" and next(server_opts) then
    vim.lsp.config(name, server_opts)
  end
  vim.lsp.enable(name)
end
