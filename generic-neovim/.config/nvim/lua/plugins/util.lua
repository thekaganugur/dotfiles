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

	-- {
	-- 	"vuki656/package-info.nvim",
	-- 	requires = "MunifTanjim/nui.nvim",
	-- 	opts = {
	-- 		autostart = true, -- Whether to autostart when `package.json` is opened
	-- 		hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
	-- 		hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3
	-- 		package_manager = "yarn",
	-- 	},
	-- },
}
