return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			win_options = {
				signcolumn = "yes:2",
			},
			keymaps = {
				["<C-h>"] = false, -- Disable to avoid conflict with window navigation
				["<C-s>"] = false, -- Disable to avoid conflict with window navigation
				["<C-l>"] = false, -- Disable to avoid conflict with window navigation
				["<C-p>"] = false, -- Disable to avoid conflict with window navigation
			},
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		init = function()
			vim.g.loaded_netrwPlugin = 1
		end,
		keys = {
			{ "-", "<cmd>keepjumps Oil<CR>", desc = "Open parent directory with Oil (without adding to jumplist)" },
		},
	},
	{
		"refractalize/oil-git-status.nvim",
		dependencies = { "stevearc/oil.nvim" },
		config = true,
	},

	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		version = "*", -- use the latest stable version
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", lazy = true },

		keys = {
			{ "<leader>-", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Open yazi at the current file" },
			{
				"<c-up>",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig | {}
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
	},
}
