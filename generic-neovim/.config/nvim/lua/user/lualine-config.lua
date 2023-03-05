require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "branch" },
		lualine_b = { "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "filetype" },
	},
	extensions = { "fugitive", "quickfix" },
})
