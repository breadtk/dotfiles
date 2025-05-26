-- ruff LSP (https://docs.astral.sh/ruff/editors/settings/)
require('lspconfig').ruff.setup {
    init_options = {
        settings = {
            lineLength = 80,
            lint = {
                enable = true
            }
        }
    }
}
