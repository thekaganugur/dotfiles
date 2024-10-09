return {
	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim", -- vscode-like icon for lsp completion items
			"hrsh7th/cmp-cmdline",
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			return {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "path" },
					{ name = "buffer" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
						-- they way you will only jump inside the snippet region
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif require("utils").has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				formatting = {
					format = require("lspkind").cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				experimental = { ghost_text = true },
			}
		end,
		config = function(_, opts)
			require("luasnip.loaders.from_vscode").lazy_load()
			local cmp = require("cmp")

			cmp.setup(opts)
			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})
			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
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

	{ "ellisonleao/glow.nvim", opts = { border = "rounded" }, cmd = "Glow" },

	{
		"axelvc/template-string.nvim",
		opts = {
			remove_template_string = true, -- remove backticks when there are no template strings
		},
	},

	{ "dmmulroy/tsc.nvim", config = true },

	-- {
	-- 	"OlegGulevskyy/better-ts-errors.nvim",
	-- 	dependencies = { "MunifTanjim/nui.nvim" },
	-- 	config = {
	-- 		keymaps = {
	-- 			toggle = "<leader>dd", -- default '<leader>dd'
	-- 			go_to_definition = "<leader>dx", -- default '<leader>dx'
	-- 		},
	-- 	},
	-- },
}
