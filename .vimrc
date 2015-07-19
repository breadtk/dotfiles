set background=dark     " enable for dark terminals
set esckeys             " map missed escape sequences (enables keypad keys)
set expandtab           " converts tabs into spaces based
set fileformat=unix     " file mode is unix
set hidden              " remember undo after quitting
set history=500         " keep 50 lines of command history
set hlsearch            " highlight search (very useful!)
set ignorecase          " case insensitive searching
set incsearch           " search incremently (search while typing)
set laststatus=2        " Always show status line
set magic               " change the way backslashes are used in search patterns
set nocompatible        " use vim-defaults instead of vi-defaults (easier, more
                        " user friendly)
set noerrorbells        " No error bells please
set number              " show line numbers
set ruler               " show cursor position in status bar
set scrolloff=5         " 5 lines above/below cursor when scrolling
set shiftwidth=2        " spaces for autoindents
set showcmd             " show typed command in status bar
set showmatch           " show matching bracket (briefly jump)
set showmode            " show mode in status bar (insert/replace/...)
set sidescrolloff=5     " 5 lines left/right
set smartcase           " but become case sensitive if you type uppercase
                        " characters
set smartindent         " smart auto indenting
set smarttab            " smart tab handling for indenting
set tabstop=2           " number of spaces a tab counts for
set textwidth=80
set title               " show file in titlebar
set ttyfast             " optimize for fast terminal connections
set viminfo='20,\"500   " remember copy registers after quitting in the .viminfo
                        " file -- 20 jump links, regs up to 500 lines'
set wildmenu            " completion with menu
syntax on               " enable colors

" A slightly more secure Vim setup
set nobackup            " no backup~ files
set noswapfile          " do not use a swap file for the buffer
set nowritebackup       " prevents Vim from writing an intermediate file before
                        " attempting to write

" Keep undo history across sessions, by storing in file.
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" Automatic commands
if has("autocmd")
  " Enable file type detection
  filetype plugin indent on
  " Treat .json files as .js
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
endif

" Remap common keys.
nore ; :
nore , ;

" Fix common typos.
command WQ wq
command Wq wq
command W w
command Q q
