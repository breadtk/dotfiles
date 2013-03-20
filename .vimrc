set nocompatible        " use vim-defaults instead of vi-defaults (easier, more user friendly)
set background=dark     " enable for dark terminals
set scrolloff=5         " 5 lines above/below cursor when scrolling
set sidescrolloff=5		  " 5 lines left/right 
set number              " show line numbers
set paste				        " fixes paste problem
set showmatch           " show matching bracket (briefly jump)
set showmode            " show mode in status bar (insert/replace/...)
set showcmd             " show typed command in status bar
set ruler               " show cursor position in status bar
set title               " show file in titlebar
set wildmenu            " completion with menu
set esckeys             " map missed escape sequences (enables keypad keys)
set noerrorbells        " No error bells please
set ignorecase          " case insensitive searching
set smartcase           " but become case sensitive if you type uppercase characters
set smartindent         " smart auto indenting
set smarttab            " smart tab handling for indenting
set magic               " change the way backslashes are used in search patterns
set nobackup            " no backup~ files.
set expandtab			      " converts tabs into spaces based
set tabstop=2           " number of spaces a tab counts for
set shiftwidth=2        " spaces for autoindents
set textwidth=80
set fileformat=unix     " file mode is unix
set viminfo='20,\"500   " remember copy registers after quitting in the .viminfo file -- 20 jump links, regs up to 500 lines'
set hidden              " remember undo after quitting
set history=500         " keep 50 lines of command history
syntax on            		" enable colors
set hlsearch         		" highlight search (very useful!)
set incsearch        		" search incremently (search while typing)
nore ; :
nore , ;

" Fix common typos.
command WQ wq
command Wq wq
command wQ wq
command W w
command Q q
