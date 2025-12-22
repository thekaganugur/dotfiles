return {
	{
		"vifm/vifm.vim",
		cmd = "Vifm",
		init = function()
			vim.keymap.set("n", "<leader>-", "<cmd>Vifm<cr>", { desc = "Vifm" })
		end,
	},

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
			},
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		init = function()
			-- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set(
				"n",
				"-",
				"<cmd>keepjumps Oil<CR>",
				{ desc = "Open parent directory with Oil (without adding to jumplist)" }
			)
		end,
	},
	{
		"refractalize/oil-git-status.nvim",
		dependencies = { "stevearc/oil.nvim" },
		config = true,
	},
}
