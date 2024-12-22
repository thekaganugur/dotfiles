return {
	{
		"saghen/blink.cmp",
		lazy = false, -- lazy loading handled internally
		dependencies = "rafamadriz/friendly-snippets",
		version = "v0.*", -- use a release tag to download pre-built binaries

		opts = {
			keymap = { preset = "super-tab" },
			appearance = {
				use_nvim_cmp_as_default = true, -- sets the fallback highlight groups to nvim-cmp's highlight groups useful for when your theme doesn't support blink.cmp will be removed in a future release, assuming themes add support
				nerd_font_variant = "mono",
			},

			-- experimental auto-brackets support
			-- accept = { auto_brackets = { enabled = true } },

			-- experimental signature help support
			-- trigger = { signature_help = { enabled = true } },
		},
	},

	-- auto pairs
	{ "echasnovski/mini.pairs", event = "VeryLazy", config = true },

	-- comments
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		opts = { enable_autocmd = false },
		config = function()
			local get_option = vim.filetype.get_option
			vim.filetype.get_option = function(filetype, option)
				return option == "commentstring"
						and require("ts_context_commentstring.internal").calculate_commentstring()
					or get_option(filetype, option)
			end
		end,
	},

	{ "kylechui/nvim-surround", event = "VeryLazy", config = true },

	{
		"axelvc/template-string.nvim",
		opts = {
			remove_template_string = true, -- remove backticks when there are no template strings
		},
	},

	{ "dmmulroy/tsc.nvim", config = true },

	{
		"kwkarlwang/bufjump.nvim",
		opts = { backward_key = "<M-o>", forward_key = "<M-ı>" },
	},
}
