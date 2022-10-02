require("windows").setup({
	animation = {
		duration = 100,
	},
	ignore = {
		buftype = { "quickfix" },
		filetype = { "NvimTree", "neo-tree", "undotree", "gundo" },
	},
})

vim.keymap.set("n", "<C-w>z", "<Cmd>WindowsMaximize<CR>")
