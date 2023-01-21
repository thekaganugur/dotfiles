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

-- -- See `:help telescope.builtin`
vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, { desc = "" })
vim.keymap.set("n", "<C-g>", require("telescope.builtin").live_grep, { desc = "" })
vim.keymap.set("n", "<leader>*", require("telescope.builtin").grep_string, { desc = "[*] Find current word" })

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").oldfiles, { desc = "[S]earch [R]ecently opened files" })
vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>s/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(
		require("telescope.themes").get_dropdown({ previewer = false })
	)
end, { desc = "[S]earch Fuzzily in [/] current buffer]" })

vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set(
	"n",
	"<leader>s:",
	require("telescope.builtin").command_history,
	{ desc = "[S]earch [:] Command History" }
)
