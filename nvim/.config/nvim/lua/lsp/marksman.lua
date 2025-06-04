-- marksman LSP (https://github.com/artempyanykh/marksman)
local util = require('lspconfig.util')

return {
    filetypes = { "markdown" },
    root_dir  = util.root_pattern(".git", ".marksman.toml"),
}
