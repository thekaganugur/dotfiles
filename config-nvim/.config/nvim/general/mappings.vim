" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Better indenting
vnoremap < <gv
vnoremap > >gv

nnoremap <silent><leader>sv :source $MYVIMRC<CR>
nnoremap <silent><leader>. :e $MYVIMRC<cr>
nnoremap <silent><leader>" :silent nohlsearch<CR>
