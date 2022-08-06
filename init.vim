source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/general/mappings.vim
source $HOME/.config/nvim/general/autocmds.vim

""" Plugins
lua require'plugins'
source $HOME/.config/nvim/plug-config/coc.vim
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

set completeopt=noinsert,noselect,menuone
