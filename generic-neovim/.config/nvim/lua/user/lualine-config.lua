local function my_location()
	local line = vim.fn.line(".")
	return string.format("%3d", line)
end

require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "branch" },
		lualine_b = { "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "", "", "filetype" },
		lualine_z = { my_location },
	},
	extensions = { "fugitive", "quickfix" },
})
