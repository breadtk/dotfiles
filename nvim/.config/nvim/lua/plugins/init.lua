return {
    -- Colorscheme.
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    -- Plugin manager
    { "folke/lazy.nvim" },

    -- LSP related
    { "neovim/nvim-lspconfig" },
    { "mason-org/mason.nvim",
    lazy = false,
    opts = {},
},
    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
        opts = {
            ensure_installed = { "lua_ls", "pyright", "marksman", "ruff" },
            automatic_installation = true,     -- install if missing
            -- this single handler will run for *every* server
            handlers = {
                -- default handler:
                function(server_name)
                    local lspconfig = require("lspconfig")
                    -- try to load your module at lua/lsp/<server_name>.lua
                    local ok, user_opts = pcall(require, "lsp." .. server_name)
                    if not ok then
                        -- no custom module? do a bare setup
                        lspconfig[server_name].setup({})
                    else
                        -- call setup() with whatever your module returned
                        lspconfig[server_name].setup(user_opts)
                    end
                end,
            },
        }
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = {
                    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = "nvim_lsp" },
                },
            })
            vim.opt.completeopt = "menu,menuone,noselect"
        end,
    },
}
