-- lua_ls LSP (https://github.com/luals/lua-language-server)
return {
  root_dir = function(bufnr)
    return vim.fs.root(bufnr, {
      '.luarc.json', '.luarc.jsonc',
      '.luacheckrc', '.stylua.toml',
      'stylua.toml', 'selene.toml',
      'selene.yml', '.git',
    })
  end,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library         = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  }
}
