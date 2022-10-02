vim.o.splitbelow = true -- Horizontal splits will automatically be below
vim.o.splitright = true -- Vertical splits will automatically be to the right
-- set diffopt+=vertical                   " Starts diff mode in vertical split

-- [[ Setting options ]]
-- See `:help vim.o`

vim.g.mapleader = " "

-- Makes popup menu smaller
vim.o.pumheight = 10

-- Treat dash separated words as a word text object"
vim.opt.iskeyword:append({ "-" })

-- Sets terminal title dynamically, instead of just 'nvim'
vim.o.title = true

-- Enable mouse
vim.o.mouse = "a"

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Save undo history
vim.o.undofile = true
vim.cmd([[set nobackup]])

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart = 99

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd([[colorscheme everforest]])
vim.o.background = "light"
vim.cmd([[let g:everforest_background = 'hard']])
vim.cmd([[let g:everforest_enable_italic = 1]])

-- vim.o.winwidth = 6
-- vim.o.winminwidth = 6
vim.o.winminheight = 0
vim.o.winminwidth = 0
vim.o.equalalways = false

-- Set completeopt to have a better completion experience
vim.opt.completeopt = { "menuone", "noselect" }

vim.cmd([[set tabstop=2]]) -- Insert 2 spaces for a tab
vim.cmd([[set shiftwidth=2]]) -- Change the number of space characters inserted for indentation
vim.cmd([[set expandtab]]) -- Converts tabs to spaces
vim.cmd([[set smartindent]]) -- Makes indenting smart
vim.cmd([[set noshowmode]]) -- Don't show --INSERT-- , --VISUAL--
vim.cmd([[set timeoutlen=400]]) -- Recommended by which-key
vim.cmd([[set scrolloff=3]]) -- Start scrolling before hitting most bottom line
vim.cmd([[set linebreak]]) -- Break the line if overflows by not character but by word
vim.cmd([[set breakindent]])
vim.cmd([[set textwidth=80]]) -- Effects gq, and color column
vim.cmd([[set colorcolumn=+1]]) -- 80 + 1 width column
