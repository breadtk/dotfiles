-- lua_ls LSP (https://github.com/luals/lua-language-server)
local util = require('lspconfig.util')

return {
  cmd       = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_dir  = util.root_pattern(
    '.luarc.json', '.luarc.jsonc',
    '.luacheckrc', '.stylua.toml',
    'stylua.toml', 'selene.toml',
    'selene.yml', '.git'
  ),
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path    = vim.split(package.path, ";"),
      },
      -- Recognize the `vim` global, so lua_ls won't warn about it
      diagnostics = {
        globals = { "vim" },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        library          = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty  = false,
      },
      telemetry = { enable = false, },
    },
  }
}
