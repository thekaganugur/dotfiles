return {
	{
		"folke/which-key.nvim", -- Show available keybindings as you type
		event = "VeryLazy",
		config = function(_, opts)
			vim.o.timeoutlen = 300
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>a", desc = "+[A]I" },
				{ "<leader>d", desc = "+[D]iagnostics" },
				{ "<leader>g", desc = "+[G]it" },
				{ "<leader>h", desc = "+[H]unks" },
				{ "<leader>s", desc = "+[S]earch" },
				{ "<leader>x", desc = "+[X] Lists" },
			})
		end,
	},

	{
		"anuvyklack/windows.nvim", -- Auto-resize and maximize the active window
		event = "VeryLazy",
		dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
		opts = {
			animation = { duration = 100 },
			ignore = {
				buftype = { "quickfix" },
				filetype = { "DiffviewFiles", "DiffviewFileHistory" },
			},
		},
		keys = { { "<C-w>z", "<Cmd>WindowsMaximize<CR>", desc = "Maximize Window" } },
		init = function()
			vim.opt.winwidth = 10
			vim.opt.winminwidth = 10
			vim.opt.equalalways = false
		end,
	},

	{
		"nvim-lualine/lualine.nvim", -- Show a lightweight statusline
		opts = {
			options = { theme = "auto", section_separators = "", globalstatus = true },
			sections = {
				lualine_a = { "branch" },
				lualine_b = { "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "filetype" },
			},
			extensions = { "fugitive", "quickfix" },
		},
	},

	{
		"MeanderingProgrammer/render-markdown.nvim", -- Render Markdown with richer inline visuals
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = { completions = { lsp = { enabled = true } } },
	},
}
