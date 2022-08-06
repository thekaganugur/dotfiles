require("dressing").setup({
	input = {
		winblend = 0,
	},
	select = {
		telescope = require("telescope.themes").get_cursor({
			initial_mode = "normal",
		}),
	},
})
