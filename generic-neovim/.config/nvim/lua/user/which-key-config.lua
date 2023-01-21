require("which-key").setup({})

local g = {
	name = "+[G]it",
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

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Better window navigation" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Better window navigation" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Better window navigation" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Better window navigation" })

vim.keymap.set("v", ">", ">gv", { desc = "Better visual indent" })
vim.keymap.set("v", "<", "<gv", { desc = "Better visual indent" })

vim.keymap.set("v", "p", '"_dP', { desc = "Paste over currently selected text without yanking it" })

vim.keymap.set("n", "<leader>-", "<cmd>Vifm<cr>", { desc = "Vifm" })
vim.keymap.set("n", "<leader>.", "<cmd>e $HOME/.config/nvim/init.vim<cr>", { desc = "Open init" })
vim.keymap.set("n", '<leader>"', "<cmd>nohlsearch<cr>", { desc = "No search" })

require("which-key").register({ s = "+[S]earch", g = g, l = "+[L]SP" }, { prefix = "<leader>" })
