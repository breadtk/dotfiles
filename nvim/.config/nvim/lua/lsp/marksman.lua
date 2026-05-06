-- marksman LSP (https://github.com/artempyanykh/marksman)
return {
    filetypes = { "markdown" },
    root_dir  = function(bufnr)
        return vim.fs.root(bufnr, { ".git", ".marksman.toml" })
    end,
}
