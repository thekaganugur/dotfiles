source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/general/mappings.vim

""" Plugins
lua require'plugins'
source $HOME/.config/nvim/plug-config/maximizer.vim
source $HOME/.config/nvim/plug-config/telescope.vim
source $HOME/.config/nvim/plug-config/fm-nvim.vim


lua require'treesitter-config'
lua require'lualine-config'
lua require'lir-config'
lua require'nvim-web-devicons-config'
lua require'telescope-config'
lua require'which-key-config'
lua require'lir.git_status'.setup()
lua require'gitsigns'.setup()
lua require'nvim-surround'.setup()

lua require'user.lsp'
lua require'user.cmp'
lua require'user.ui'
lua require'user.autocommands'
lua require'user.autopairs'
lua require'user.illuminate'
lua require'user.signature'
lua require'user.comment'
lua require'user.auto_dark_mode'
lua require'colorizer'.setup()
lua require('bqf').setup({preview = {auto_preview = false}})

command Format execute "lua vim.lsp.buf.formatting()"
command FormatAuto execute 'lua vim.api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()" })'

let g:Illuminate_ftblacklist = ['TelescopePrompt', 'qf', 'lir']
 
let g:cursorhold_updatetime = 200





au FileType qf call AdjustWindowHeight(4, 8)
" au FileType fugitive call AdjustWindowHeight(8, 10)

function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
