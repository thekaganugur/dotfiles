" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Better indenting
vnoremap < <gv
vnoremap > >gv

nnoremap <silent><leader>sv :source $HOME/.config/nvim/init.vim<CR>
nnoremap <silent><leader>. :e $HOME/.config/nvim/init.vim<CR>
nnoremap <silent><leader>" :silent nohlsearch<CR>
nnoremap <silent><leader>- :silent Vifm<CR>
