let g:mapleader = "\<Space>"

set pumheight=10                        " Makes popup menu smaller
set iskeyword+=-                      	" Treat dash separated words as a word text object"
set title                               " Sets terminal title dynamically, instead of just 'nvim'
set mouse=a                             " Enable mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
" set diffopt+=vertical                   " Starts diff mode in vertical split
set termguicolors                       " Better colors
set tabstop=2                           " Insert 2 spaces for a tab
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set noshowmode                          " Don't show --INSERT-- , --VISUAL--

set timeoutlen=400                      " Recommended by which-key 
set ignorecase                          " Ignore casing during searches
set smartcase                           " Makes the search pattern case-sensitive whenever it containers uppercase characters)
set scrolloff=3                         " Start scrolling before hitting most bottom line
set linebreak                           " Break the line if overflows by not character but by word
set textwidth=80                        " Effects gq, and color column
set colorcolumn=+1                      " 80 + 1 width column

set nobackup
set undofile                            " Store undo info in a file

let g:loaded_netrw       = 1            " Disable netrw
let g:loaded_netrwPlugin = 1            " Disable netrw

set foldmethod=expr                     " Use expression for folding
set foldexpr=nvim_treesitter#foldexpr() " Use treesitter for expression
set foldlevelstart=99                   " Do not fold eveything at startup

set signcolumn=yes:1


""" Color
colorscheme everforest
set background=light
let g:everforest_background = 'hard'
let g:everforest_enable_italic = 1
let g:everforest_disable_italic_comment = 1
