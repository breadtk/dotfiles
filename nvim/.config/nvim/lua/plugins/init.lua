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
    { "mason-org/mason.nvim",
    lazy = false,
    opts = {},
},
    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
        opts = {
            ensure_installed = require("servers"),
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            require("lsp")
        end,
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local cmp = require("cmp")
            vim.opt.completeopt = "menu,menuone,noselect"
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                },
            })
        end,
    },
}
