return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
	init = function()
    -- stylua: ignore start
		vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, { desc = "" })
		vim.keymap.set("n", "<C-g>", require("telescope.builtin").live_grep, { desc = "" })
		vim.keymap.set("n", "<leader>*", require("telescope.builtin").grep_string, { desc = "[*] Find current word" })
		vim.keymap.set("n", "<leader>sr", require("telescope.builtin").oldfiles, { desc = "[S]earch [R]ecently opened files" })
		vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[S]earch [B]uffers" })
		vim.keymap.set("n", "<leader>s/", function() require("telescope.builtin").current_buffer_fuzzy_find( require("telescope.themes").get_dropdown({ previewer = false })) end, { desc = "[S]earch Fuzzily in [/] current buffer]" })
		vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set( "n", "<leader>s:", require("telescope.builtin").command_history, { desc = "[S]earch [:] Command History" })
		-- stylua: ignore end
	end,
	opts = {
		pickers = {
			lsp_definitions = { initial_mode = "normal" },
			lsp_type_definitions = { initial_mode = "normal" },
			lsp_implementations = { initial_mode = "normal" },
			lsp_references = { initial_mode = "normal" },
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("fzf")
	end,
}

--git
-- {"<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "List Stash"},
-- {"<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file"},
-- {"<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch"},
-- {"<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit"},
-- {"<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Checkout commit(for current file)"}
