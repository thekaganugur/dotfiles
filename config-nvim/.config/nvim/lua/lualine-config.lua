require("lualine").setup({
	options = {
		theme = "everforest",
		section_separators = { "", "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "branch" },
		lualine_b = { "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "", "", "filetype" },
	},
	extensions = { "fugitive", "quickfix" },
})
