require("windows").setup({
	animation = {
		duration = 100,
	},
	ignore = {
		buftype = { "quickfix" },
		filetype = { "NvimTree", "neo-tree", "undotree", "gundo", "lir" },
	},
})

vim.keymap.set("n", "<C-w>z", "<Cmd>WindowsMaximize<CR>", { desc = "Maximize Window" })
