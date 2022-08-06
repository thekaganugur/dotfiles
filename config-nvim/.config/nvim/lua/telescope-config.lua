require("telescope").setup({
	pickers = {
		lsp_definitions = {
			initial_mode = "normal",
		},
		lsp_type_definitions = {
			initial_mode = "normal",
		},

		lsp_implementations = {
			initial_mode = "normal",
		},

		lsp_references = {
			initial_mode = "normal",
		},
	},

	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

require("telescope").load_extension("fzf")
