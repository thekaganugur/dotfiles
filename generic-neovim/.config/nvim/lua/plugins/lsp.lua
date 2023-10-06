return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{ "pmizio/typescript-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
		},
		opts = {
			servers = {
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
				tailwindcss = {
					settings = {
						tailwindCSS = {
							experimental = { classRegex = { { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" } } },
						},
					},
				},
			},
		},
		config = function(_, opts)
			local configuredServers = { "tsserver" } -- tsserver is because we will ignore it.
			for server, _ in pairs(opts.servers) do
				table.insert(configuredServers, server)
				require("lspconfig")[server].setup(opts.servers[server])
			end

			local installed_servers = require("mason-lspconfig").get_installed_servers()
			for _, server in ipairs(require("utils").filter_servers(installed_servers, configuredServers)) do
				require("lspconfig")[server].setup({})
			end

			require("lspconfig").util.default_config =
				vim.tbl_deep_extend("force", require("lspconfig").util.default_config, {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				})
		end,
		init = function()
			require("utils").on_attach(function(_client, buffer)
				require("config.lsp").lsp_keymappings(buffer)
				require("config.lsp").lsp_handlers()
			end)
		end,
	},

	{
		"stevearc/conform.nvim",
		init = function()
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "beautysh" },
				zsh = { "beautysh" },

				javascript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				vue = { { "prettierd", "prettier" } },
				css = { { "prettierd", "prettier" } },
				scss = { { "prettierd", "prettier" } },
				less = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				json = { { "prettierd", "prettier" } },
				jsonc = { { "prettierd", "prettier" } },
				yaml = { { "prettierd", "prettier" } },
				markdown = { { "prettierd", "prettier" } },
				["markdown.mdx"] = { { "prettierd", "prettier" } },
				graphql = { { "prettierd", "prettier" } },
				handlebars = { { "prettierd", "prettier" } },
			},
		},
	},

	-- cmdline tools and lsp servers
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = true,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"bash-language-server",
				"beautysh",
				"css-lsp",
				"eslint-lsp",
				"html-lsp",
				"json-lsp",
				"lua-language-server",
				"marksman",
				"prettierd",
				"stylua",
				"tailwindcss-language-server",
				"yaml-language-server",
				"typescript-language-server",
			},
		},
	},
}
