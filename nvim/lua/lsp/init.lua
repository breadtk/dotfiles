-- lua/lsp/init.lua
local servers = { "lua_ls", "pyright", "marksman", "ruff" }

-- global LSP settings
vim.opt.updatetime = 250
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- Call each LSP server's
for _, name in ipairs(servers) do
  require("lsp." .. name)
end

