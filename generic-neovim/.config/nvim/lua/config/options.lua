vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt

-- Undo and History
opt.undofile = true
opt.undolevels = 10000

-- Window Behavior
opt.breakindent = true
opt.linebreak = true
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- UI Appearance
opt.ruler = false
opt.showmode = false
opt.wrap = false
opt.colorcolumn:append("+1")
opt.signcolumn = "yes"
opt.pumheight = 10

-- Search
opt.ignorecase = true
opt.infercase = true
opt.smartcase = true

-- Editing
opt.smartindent = true
opt.completeopt = "menuone,noinsert,noselect"
opt.virtualedit = "block"
opt.textwidth = 80
opt.scrolloff = 5

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- Misc
opt.iskeyword:append({ "-" })
opt.updatetime = 250
opt.shortmess:append({ W = true, I = true, c = true, C = true })
