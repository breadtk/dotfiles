" Basic behavior
set autoindent                  " Makes identation logic smarter
set autoread                    " If a file changes on disk, reload it in vim.
set background=light            " Enable for dark terminals
set backspace=indent,eol,start  " Ensures backspace works at start and eol.
set esckeys                     " Map missed escape sequences (enables keypad keys)
set expandtab                   " Converts tabs into spaces based
set fileformat=unix             " File mode is unix
set hidden                      " Remember undo after quitting
set history=500                 " Keep 500 lines of command history
set hlsearch                    " Highlight search (very useful!)
set ignorecase                  " Case insensitive searching
set incsearch                   " Search incremently (search while typing)
set laststatus=2                " Always show status line
set magic                       " Change the way backslashes are used in search patterns
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
set tabstop=4                   " Number of spaces a tab counts for
set textwidth=80                " Line wrap after 80 chars.
set title                       " Show file in titlebar
set ttyfast                     " Optimize for fast terminal connections
set wildmenu                    " Completion with menu


" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif


" Sane default file encoding
if &encoding ==# 'latin1' && has('gui_running')
    set encoding=utf-8
endif


" Enable color syntax support
if has('syntax') && !exists('g:syntax_on')
    syntax enable
endif


" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j 
endif


" A slightly more secure Vim setup. It prevents a bunch of unnecessary files
" from being written to disk. Some current and past session information will
" continue to persist though.
set nobackup            " Do not create backup files (e.g. filename~)
set noswapfile          " Do not use a swap file for the buffer
set nowritebackup       " Prevents Vim from writing an intermediate file before
                        " attempting to write explicitly
set viminfo='20,\"500   " Remember copy registers after quitting in the 
                        " ~/.viminfo file -- 20 jump links, regs up to 500
                        " lines'
" Keep undo history across sessions, by storing in file.
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
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


" Transparent editing of encrypted files.
" by Osman Surkatty
" based on a script by Wouter Hanegraaff
augroup encrypted
    " Since Vim 7.4, Vim has supported Blowfish based file encryption. This
    " augroup will transparently encrypt and decrypt *.enc files using a common
    " symmetric key pulled from $HOME/.vim/encryption_key.
    "
    " Some important things to consider:
    " * You will use the same password for all *.enc files
    " * Encryption strength is commensurate to password strength
    " * Blowfish provides no integrity protection, only confidentiality
    " * If you lose/corrupt your password file, encrypted files are irrecoverable
    " * Some state may be plaintext on disk/memory unexpectedly
    "
    " For more information about Vim's built-in library, refer to:
    "   :help encryption
    "
    au!

    " Make sure nothing is written to ~/.viminfo while editing an encrypted
    " file.
    autocmd BufReadPre,BufNewFile,FileReadPre *.enc set viminfo=

    " Prevent writing of some unencrypted data to disk
    autocmd BufReadPre,BufNewFile,FileReadPre *.enc set noswapfile noundofile nobackup

    " Read in the key file
    autocmd BufReadPre,BufNewFile,FileReadPre *.enc let encryption_key = readfile(expand("$HOME/.vim/encryption_key"), 1)[0]

    " Set encryption key for the session
    autocmd BufReadPre,BufNewFile,FileReadPre *.enc execute "set key=".encryption_key 

    " Unset encryption_key var after file has been read to protect it
    autocmd BufReadPost,BufNewFile,FileReadPost *.enc let encryption_key = ""
augroup END

" Automatic commands
if has("autocmd")
  " Enable file type detection
  filetype plugin indent on

  " Fix syntax on certain filestypes
  autocmd BufNewFile,BufRead *.json set filetype=json syntax=javascript
  autocmd BufNewFile,BufRead *.md set filetype=markdown syntax=markdown
endif

" Remap common keys.
nore ; :
nore , ;

" Fix common typos.
command WQ wq
command Wq wq
command W w
command Q q

" Vimwiki
let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md.enc'}]
