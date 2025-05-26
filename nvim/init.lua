-- ~/.config/nvim/init.lua

-------------------------------------------------------------------------------
-- Bootstrap plugins via lazy.nvim.
-------------------------------------------------------------------------------
-- Leader keys MUST be configured prior to setting up lazy.nvim
vim.g.mapleader       = ' '
vim.g.maplocalleader  = '\\'

-- Run lazy.nvim for plugin management.
require("lazy_setup")

-- Enable colorscheme
vim.o.termguicolors = true
vim.cmd[[colorscheme tokyonight]]


-------------------------------------------------------------------------------
-- General options
-------------------------------------------------------------------------------
vim.opt.autoindent        = true
vim.opt.autoread          = true
vim.opt.backspace         = { 'indent', 'eol', 'start' }
vim.opt.clipboard         = 'unnamedplus'
vim.opt.expandtab         = true
vim.opt.fileformat        = 'unix'
vim.opt.hidden            = true
vim.opt.history           = 500
vim.opt.hlsearch          = true
vim.opt.ignorecase        = true
vim.opt.incsearch         = true
vim.opt.laststatus        = 2
vim.opt.mouse             = 'a'
vim.opt.errorbells        = false
vim.opt.number            = true
vim.opt.ruler             = true
vim.opt.scrolloff         = 5
vim.opt.shiftwidth        = 4
vim.opt.showcmd           = true
vim.opt.showmatch         = true
vim.opt.showmode          = true
vim.opt.sidescrolloff     = 5
vim.opt.signcolumn        = "yes"
vim.opt.smartcase         = true
vim.opt.smartindent       = true
vim.opt.smarttab          = true
vim.opt.tabstop           = 4
vim.opt.textwidth         = 80
vim.opt.title             = true
vim.opt.wildmenu          = true


-------------------------------------------------------------------------------
-- Filetype & syntax
-------------------------------------------------------------------------------
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')


-------------------------------------------------------------------------------
-- Backup, swap, & undo files.
-------------------------------------------------------------------------------
local cache = vim.env.XDG_CACHE_HOME or vim.fn.stdpath('cache')
local undopath  = cache .. '/nvim/backups'
vim.fn.mkdir(undopath, 'p')
vim.opt.backup      = false
vim.opt.swapfile    = false
vim.opt.writebackup = false
vim.opt.shada       = "'20,\"500"
vim.opt.undodir     = undopath
vim.opt.undofile    = true

-------------------------------------------------------------------------------
-- Restore cursor position on buffer read.
-------------------------------------------------------------------------------
local resCur = vim.api.nvim_create_augroup("resCur", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = resCur,
  callback = function()
    -- Get the last cursor position mark
    local last_pos = vim.fn.line("'\"")
    -- If it's valid (not the first line), not past end, and not a gitcommit buffer
    if last_pos > 1
      and last_pos <= vim.fn.line("$")
      and vim.bo.filetype ~= "gitcommit"
    then
      -- Jump to it
      vim.cmd([[normal! g`"]])
    end
  end,
})



-------------------------------------------------------------------------------
-- File-specific tweaks
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = '*.md',
    callback = function() vim.bo.filetype = 'markdown' end,
})


-------------------------------------------------------------------------------
-- Keymaps
-------------------------------------------------------------------------------
local map_opts = { noremap = true, silent = true }
vim.keymap.set({ 'n', 'v', 'o' }, ',', ';', map_opts)
vim.keymap.set({ 'n', 'v', 'o' }, ';', ':', map_opts)


-------------------------------------------------------------------------------
-- Fix common typos.
-------------------------------------------------------------------------------
vim.api.nvim_create_user_command('Q', 'q<bang>',
{ bang = true, nargs = 0, desc = 'Quit (typo fix)' })

vim.api.nvim_create_user_command('W', 'w<bang>',
{ bang = true, nargs = 0, desc = 'Write (typo fix)' })

vim.api.nvim_create_user_command('WQ', 'wq<bang>',
{ bang = true, nargs = 0, desc = 'Write & Quit (typo fix)' })

vim.api.nvim_create_user_command('Wq', 'wq<bang>',
{ bang = true, nargs = 0, desc = 'Write & Quit (typo fix)' })

