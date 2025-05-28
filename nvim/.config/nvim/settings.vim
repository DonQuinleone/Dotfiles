" set leader key
let g:mapleader = "\<Space>"

hi Normal guibg=NONE ctermbg=NONE
set hidden
set encoding=utf-8
set pumheight=10
set fileencoding=utf-8
set ruler
set cmdheight=2
set iskeyword+=-
set splitbelow
set splitright
set conceallevel=0
set tabstop=2
set shiftwidth=2
set smarttab
set expandtab
set smartindent
set autoindent
set laststatus=0
set number
set relativenumber
set cursorline
set showtabline=2
set noshowmode
set nobackup
set nowritebackup
set updatetime=300
set timeoutlen=500
set formatoptions-=cro
set autochdir
au! BufWritePost $MYVIMRC source %
set mouse=nicr
set spelllang=en
set spellfile=$HOME/.config/nvim/spell/en.utf-8.add
set spell
set clipboard+=unnamedplus
filetype indent on

cmap w!! w !sudo tee %



" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif


let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:python_highlight_all = 1

