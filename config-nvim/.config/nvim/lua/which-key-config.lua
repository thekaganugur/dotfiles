local wk = require("which-key")

wk.setup({})

-- local l = {
-- 	name = "lsp",
-- 	["."] = { "<cmd>CocConfig<cr>", "config" },
-- 	a = { "<plug>(coc-codeaction-cursor)", "action under cursor" },
-- 	A = { "<plug>(coc-codeaction)", "action for file" },
-- 	c = { "<cmd>Telescope coc commands<cr>", "coc commands" },
-- 	d = { "<cmd>Telescope coc diagnostics<cr>", "diagnostics" },
-- 	i = { "<cmd>Telescope coc implementations initial_mode=normal<cr>", "implementations" },
-- 	n = { "<Plug>(coc-diagnostic-next)", "next diagnostic" },
-- 	N = { "<Plug>(coc-diagnostic-next-error)", "next error" },
-- 	o = { "<cmd>Telescope coc document_symbols<cr>", "outline" },
-- 	p = { "<Plug>(coc-diagnostic-prev)", "prev diagnostic" },
-- 	P = { "<Plug>(coc-diagnostic-prev-error)", "prev error" },
-- 	r = { "<cmd>Telescope coc references initial_mode=normal<cr>", "references" },
-- 	R = { "<Plug>(coc-rename)", "rename" },
-- 	s = { "<cmd>Telescope coc workspace_symbols<cr>", "workspace symbols" },
-- 	t = { "<cmd>Telescope coc type_definitions initial_mode=normal<cr>", "type definition" },
-- }

local f = {
	name = "fuzzy",
	-- b = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Buffers" },
	-- h = { "<cmd>lua require('telescope.builtin').help_tags()<cr>" },

	g = { "<cmd>Telescope git_files<cr>", "Git Files" },
	r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
	c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
	z = { "<cmd>Telescope zoxide list<cr>", "Zoxide " },
	["-"] = { "<cmd>lua require('telescope.builtin').file_browser()<cr>" },
	["*"] = { "<cmd>lua require('telescope.builtin').grep_string()<cr>", "Grep hovered" },
}

local g = {
	name = "+Git",
	j = { "<cmd>Gitsigns next_hunk<cr>", "Next Hunk" },
	k = { "<cmd>Gitsigns prev_hunk<cr>", "Prev Hunk" },
	p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview Hunk" },
	r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
	R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset Buffer" },
	s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
	u = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Undo Stage Hunk" },
	S = { "<cmd>Telescope git_stash<cr>", "List Stash" },
	o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
	b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle line blame" },
	B = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
	c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
	C = { "<cmd>Telescope git_bcommits<cr>", "Checkout commit(for current file)" },
	q = { "<cmd>Gitsigns setqflist<cr>", "Git changes qf" },
	-- v = { "<cmd>GV", "view commits" },
	-- V = { "<cmd>GV!", "view buffer commits" },
}

local z = {
	name = "+Zen",
	s = { "<cmd>TZBottom<cr>", "toggle status line" },
	t = { "<cmd>TZTop<cr>", "toggle tab bar" },
	z = { "<cmd>TZAtaraxis<cr>", "toggle zen" },
}

wk.register({ ["."] = "vimrc", f = f, l = l, g = g, z = z }, { prefix = "<leader>" })
