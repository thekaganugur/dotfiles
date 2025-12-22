return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			dependencies = "rafamadriz/friendly-snippets",
			version = "v2.*",
			init = function()
				require("luasnip.loaders.from_vscode").lazy_load()
				require("luasnip").filetype_extend("typescript", { "javascript" })
			end,
		},
		version = "1.*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default",
				["<C-h>"] = { "snippet_backward" },
				["<C-l>"] = { "snippet_forward" },

			},
			appearance = { nerd_font_variant = "mono" },
			signature = {
				enabled = true,
				window = {
					max_height = 4,
					max_width = 80,
					treesitter_highlighting = false,
				},
			},
			snippets = { preset = "luasnip" },
		},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

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

	{
		"typed-rocks/ts-worksheet-neovim",
		opts = {},
	},
}
