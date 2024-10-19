return {
	{
		"sainnhe/everforest",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		init = function()
			vim.cmd.colorscheme("everforest")
			vim.g.everforest_background = "hard"
			vim.g.everforest_enable_italic = true
			vim.api.nvim_create_autocmd({ "ColorScheme" }, {
				callback = function()
					-- vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { link = "DiagnosticInfo" })
				end,
			})
		end,
	},
	{
		"cormacrelf/dark-notify",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("dark_notify").run()
		end,
	},
}
