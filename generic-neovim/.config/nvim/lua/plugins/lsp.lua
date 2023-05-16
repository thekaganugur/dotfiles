return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = {
			servers = {
				tsserver = {
					init_options = {
						plugins = {
							{ name = "typescript-lit-html-plugin", location = vim.env.NODE_LIB },
							{ name = "typescript-styled-plugin", location = vim.env.NODE_LIB },
						},
					},
				},
				eslint = {
					on_attach = function(_, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, command = "EslintFixAll" })
					end,
					handlers = {
						["eslint/noLibrary"] = function()
							vim.notify_once("[lspconfig] Unable to find ESLint library.", vim.log.levels.INFO)
							return {}
						end,
					},
				},
			},
		},
		config = function(_, opts)
			require("lspconfig").tsserver.setup(opts.servers.tsserver)
			require("lspconfig").eslint.setup(opts.servers.eslint)

			local installed_servers = require("mason-lspconfig").get_installed_servers()
			installed_servers = require("utils").filter_servers(installed_servers, { "eslint", "tsserver" })
			for _, server in ipairs(installed_servers) do
				require("lspconfig")[server].setup({})
			end
		end,
		init = function()
			require("utils").on_attach(function(client, buffer)
				require("config.lsp").lsp_formatting(client, buffer)
				require("config.lsp").lsp_keymappings(buffer)
				require("config.lsp").lsp_handlers()
			end)
		end,
	},

	-- formatters
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			return {
				sources = {
					require("null-ls").builtins.formatting.stylua,
					require("null-ls").builtins.formatting.prettierd,
					require("null-ls").builtins.formatting.beautysh,
				},
			}
		end,
	},

	-- cmdline tools and lsp servers
	{ "williamboman/mason.nvim", cmd = "Mason", config = true },

	-- async formatting on save
	{
		"lukas-reineke/lsp-format.nvim",
		event = { "BufReadPre", "BufNewFile" },
		init = function()
			-- https://github.com/lukas-reineke/lsp-format.nvim#wq-will-not-format-when-not-using-sync
			vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]])
		end,
		config = true,
	},
}
