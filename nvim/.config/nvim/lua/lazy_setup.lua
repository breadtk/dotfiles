-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Both `mapleader` and `maplocalleader` must be set before running
-- lazy.setup(), so plugins that get setup by lazy have their mappings are
-- correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Run lazy.nvim setup
local uv = vim.uv or vim.loop
local config_path = vim.fn.stdpath("config")
local salt_file = config_path .. "/lazy-lock.salt"
local salt
if vim.fn.filereadable(salt_file) == 1 then
    salt = vim.fn.readfile(salt_file)[1]
else
    math.randomseed(uv.hrtime())
    salt = vim.fn.sha256(tostring(math.random()))
    vim.fn.writefile({ salt }, salt_file)
end
local hostname = uv.os_gethostname()
local host_hash = vim.fn.sha256(hostname .. salt)
require("lazy").setup({
    spec = {
        -- import plugins directory
        { import = "plugins" }
    },
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "tokyonight" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
    lockfile = config_path .. "/lazy-lock." .. host_hash .. ".json",
})
