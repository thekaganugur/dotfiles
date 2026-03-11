return {
	-- measure startuptime
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},

	-- library used by other plugins
	{ "nvim-lua/plenary.nvim", lazy = true },

	-- library used by other plugins, vscode-like icon for lsp completion items
	{ "onsails/lspkind.nvim", lazy = true },

	-- library used by other plugins to show icons
	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
