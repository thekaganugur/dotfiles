vim.g.mapleader = " " -- Use space as the one and only true Leader key

local o = vim.opt

o.undofile = true -- Save undo history
o.undolevels = 10000

-- o.backup = false -- Don't store backup while overwriting the file
-- o.writebackup = false -- Don't store backup while overwriting the file

-- Appearance
o.breakindent = true -- Indent wrapped lines to match line start
o.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
o.splitbelow = true -- Horizontal splits will be below
o.splitright = true -- Vertical splits will be to the right
o.splitkeep = "screen" -- Reduce scroll during window split

o.ruler = false -- Don't show cursor position in command line
o.showmode = false -- Don't show mode in command line
o.wrap = false -- Display long lines as just one line
o.colorcolumn:append("+1") -- 80 + 1 width column

o.signcolumn = "yes" -- Always show sign column (otherwise it will shift text)
o.pumheight = 10 -- Makes popup menu smaller

-- Editing
o.ignorecase = true -- Ignore case when searching (use `\C` to force not doing that)
o.infercase = true -- Infer letter cases for a richer built-in keyword completion
o.smartcase = true -- Don't ignore case when searching if pattern has upper case
o.smartindent = true -- Make indenting smart

o.completeopt = "menuone,noinsert,noselect" -- Customize completions
o.virtualedit = "block" -- Allow going past the end of line in visual block mode
o.textwidth = 80 -- Effects gq, and color column
o.tabstop = 2 -- Number of spaces tabs count for
o.shiftwidth = 2 -- Size of an indent
o.iskeyword:append({ "-" }) -- Treat dash separated words as a word text object"
o.scrolloff = 5 -- Lines of context

o.updatetime = 250 -- Save swap file and trigger CursorHold
o.expandtab = true -- Use spaces instead of tabs

o.shortmess:append({ W = true, I = true, c = true, C = true })
