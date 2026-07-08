vim.g.mapleader = " " -- Prefix for custom shortcuts
vim.g.maplocalleader = "," -- Secondary prefix for local shortcuts

local opt = vim.opt

-- Undo and History
opt.undofile = true -- Keep undo history across sessions
opt.undolevels = 10000 -- Allow long undo chains

-- Window Behavior
opt.breakindent = true -- Wrapped lines follow existing indentation
opt.linebreak = true -- Break wrapped lines at word boundaries
opt.splitbelow = true -- New horizontal splits open underneath
opt.splitright = true -- New vertical splits open to the right
opt.splitkeep = "screen" -- Avoid shifting the visible area on split

-- UI Appearance
opt.ruler = false -- Leave cursor position out of the command line
opt.showmode = false -- Let the statusline handle mode display
opt.wrap = false -- Keep long lines on a single screen row
opt.colorcolumn:append("+1") -- Show an over-limit guide after 80 columns
opt.signcolumn = "yes" -- Prevent text from shifting when signs appear
opt.pumheight = 10 -- Keep completion menus from growing too tall

-- Search
opt.ignorecase = true -- Lowercase searches match any case
opt.infercase = true -- Keyword completion mirrors typed casing
opt.smartcase = true -- Capital letters make searches case-sensitive

-- Editing
opt.smartindent = true -- Follow basic indentation rules while typing
opt.completeopt = "menuone,noinsert,noselect" -- Require explicit confirmation from completion
opt.virtualedit = "block" -- Let visual block mode reach past end of line
opt.textwidth = 80 -- Auto-wrap text once it reaches 80 columns
opt.scrolloff = 5 -- Keep a few lines of context around the cursor

-- Indentation
opt.tabstop = 2 -- Render tab characters at two columns
opt.shiftwidth = 2 -- Use two columns for indent commands
opt.expandtab = true -- Pressing Tab inserts spaces

-- Misc
opt.iskeyword:append({ "-" }) -- Keep dashed names as one word
opt.updatetime = 250 -- Trigger idle-based updates more quickly
opt.shortmess:append({ W = true, I = true, c = true }) -- Suppress low-value startup and completion messages

opt.foldlevel = 99 -- Leave most folds expanded during editing
opt.foldlevelstart = 99 -- Open files with folds already expanded
opt.foldminlines = 2 -- Avoid creating one-line folds

vim.o.winborder = "rounded"
