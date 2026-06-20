return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			dependencies = "rafamadriz/friendly-snippets",
			init = function()
				require("luasnip.loaders.from_vscode").lazy_load()
				require("luasnip").filetype_extend("typescript", { "javascript" })
			end,
		},

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default",
				["<C-h>"] = { "snippet_backward" },
				["<C-l>"] = { "snippet_forward" },
			},
			appearance = { nerd_font_variant = "mono" },

			completion = {
				menu = { border = "none" },
			},
			signature = {
				enabled = true,
				window = { max_height = 4, max_width = 80, treesitter_highlighting = false },
			},
			snippets = { preset = "luasnip" },
		},
	},

	{ "folke/ts-comments.nvim", event = "VeryLazy", opts = {} }, -- Use treesitter-aware comment strings
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} }, -- Close pairs while typing
	{ "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} }, -- Auto-close and rename matching tags
	{ "kylechui/nvim-surround", event = "VeryLazy", opts = {} }, -- Add, change, and delete surrounds
	{ "axelvc/template-string.nvim", opts = { remove_template_string = true } }, -- Switch quotes to backticks when needed
	{
		"andrewferrier/debugprint.nvim", -- Insert temporary print-style debugging lines
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local js_like = { left = 'console.log("', right = '")', mid_var = '", ', right_var = ")" }
			return {
				filetypes = {
					["javascript"] = js_like,
					["javascriptreact"] = js_like,
					["typescript"] = js_like,
					["typescriptreact"] = js_like,
				},
			}
		end,
	},
	{ "brenoprata10/nvim-highlight-colors", event = { "BufReadPre", "BufNewFile" }, opts = {} }, -- Preview color values inline
}
