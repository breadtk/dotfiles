" Save in ~/.config/nvim/init.vim

" Basic behavior
set autoindent                  " Makes identation logic smarter
set autoread                    " If a file changes on disk, reload it in vim.
set background=light            " Enable for dark terminals
set backspace=indent,eol,start  " Ensures backspace works at start and eol.
set expandtab                   " Converts tabs into spaces based
set fileformat=unix             " File mode is unix
set hidden                      " Remember undo after quitting
set history=500                 " Keep 500 lines of command history
set hlsearch                    " Highlight search (very useful!)
set ignorecase                  " Case insensitive searching
set incsearch                   " Search incremently (search while typing)
set laststatus=2                " Always show status line
set magic                       " Change the way backslashes are used in search patterns
set mouse=a                     " Enable mouse support in all modes.
set nocompatible                " Use vim-defaults instead of vi-defaults (easier, more
                                " user friendly)
set noerrorbells                " No error bells
set number                      " Show line numbers
set ruler                       " Show cursor position in status bar
set scrolloff=5                 " 5 lines above/below cursor when scrolling
set shiftwidth=4                " Spaces for autoindents
set showcmd                     " Show typed command in status bar
set showmatch                   " Show matching bracket (briefly jump)
set showmode                    " Show mode in status bar (insert/replace/...)
set sidescrolloff=5             " 5 lines left/right
set smartcase                   " But become case sensitive if you type uppercase
                                " characters
set smartindent                 " Smart auto indenting
set smarttab                    " Smart tab handling for indenting
set t_Co=256                    " Colors
set tabstop=4                   " Number of spaces a tab counts for
set textwidth=80                " Line wrap after 80 chars.
set title                       " Show file in titlebar
set wildmenu                    " Completion with menu

" Sane default file encoding
if &encoding ==# 'latin1'
    set encoding=utf-8
endif

syntax enable " Enable color syntax support
filetype plugin indent on " Enable file type detection

" A slightly more secure Nvim setup. It prevents a bunch of unnecessary files
" from being written to disk. Some current and past session information will
" continue to persist though.
set nobackup            " Do not create backup files (e.g. filename~)
set noswapfile          " Do not use a swap file for the buffer
set nowritebackup       " Prevents Nvim from writing an intermediate file before
                        " attempting to write explicitly
set shada='20,\"500     " Remember copy registers after quitting 20 jump links,
                        " regs up to 500 lines'
" Keep undo history across sessions, by storing in file.
silent !mkdir ~/.nvim/backups > /dev/null 2>&1
set undodir=~/.nvim/backups
set undofile

" Restore cursor to file position in a previous editing session.
" Source: Bram Moolenaar via Vim 8.1 defaults.vim file
augroup resCur
    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd!
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif
augroup END

" Fix syntax on certain filestypes
autocmd BufNewFile,BufRead *.json set filetype=json syntax=javascript
autocmd BufNewFile,BufRead *.md set filetype=markdown syntax=markdown

" Remap common keys.
nore ; :
nore , ;

" Fix common typos.
command WQ wq
command Wq wq
command W w
command Q q
