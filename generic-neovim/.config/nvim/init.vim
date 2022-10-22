lua require'plugins'
lua require'user.settings'
lua require'user.treesitter-config'
lua require'user.lualine-config'
lua require'user.lir-config'
lua require'user.nvim-web-devicons-config'
lua require'user.telescope-config'
lua require'user.which-key-config'
lua require'user.lsp'
lua require'user.cmp'
lua require'user.dressing'
lua require'user.autocommands'
lua require'user.autopairs'
lua require'user.illuminate'
lua require'user.signature'
lua require'user.comment'
lua require'user.windows'

lua require'colorizer'.setup()
lua require('bqf').setup({preview = {auto_preview = false}})
lua require("document-color").setup({ mode = "background",  }) -- "background" | "foreground" | "single"
lua require'lir.git_status'.setup()
lua require'gitsigns'.setup()
lua require'nvim-surround'.setup()

"----------------
au FileType qf call AdjustWindowHeight(4, 8)
" au FileType fugitive call AdjustWindowHeight(8, 10)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

source $HOME/.config/nvim/general/mappings.vim
"----------------
