return {
	-- better vim.ui
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = { win_options = { winblend = 0 } },
			select = { telescope = require("telescope.themes").get_cursor({ initial_mode = "normal" }) },
		},
	},

	-- lsp symbol navigation breadcrumblike
	{
		"utilyre/barbecue.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "SmiteshP/nvim-navic" },
		opts = { show_dirname = false, kinds = require("lspkind").symbol_map },
	},

	{
		"anuvyklack/windows.nvim",
		event = "VeryLazy",
		dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
		opts = {
			animation = { duration = 100 },
			ignore = {
				buftype = { "quickfix" },
				filetype = { "NvimTree", "neo-tree", "undotree", "gundo", "lir" },
			},
		},
		init = function()
			vim.opt.winwidth = 10
			vim.opt.winminwidth = 10
			vim.opt.equalalways = false
			vim.keymap.set("n", "<C-w>z", "<Cmd>WindowsMaximize<CR>", { desc = "Maximize Window" })
		end,
	},

	-- statusline
	{
		"hoob3rt/lualine.nvim",
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

	-- icons
	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
