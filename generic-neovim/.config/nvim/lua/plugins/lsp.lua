return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{ "yioneko/nvim-vtsls", config = function() end },
		},
		opts = {
			servers = {
				vtsls = {
					settings = {
						typescript = {
							inlayHints = {
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								variableTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								enumMemberValues = { enabled = true },
							},
							importModuleSpecifier = "relative",
							pluginPaths = "relative",
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
				tailwindcss = {
					settings = {
						tailwindCSS = {
							experimental = { classRegex = { { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" } } },
						},
					},
				},
				cssls = {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				},
			},
		},
		config = function(_, opts)
			local configuredServers = { "" }
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
			format_on_save = {
				lsp_fallback = true, -- Attempt LSP formatting if no formatters are available
			},
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "beautysh" },
				zsh = { "beautysh" },

				-- javascript = { "prettierd", "prettier", stop_after_first = true },
				-- javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				-- typescript = { "prettierd", "prettier", stop_after_first = true },
				-- typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				-- vue = { "prettierd", "prettier", stop_after_first = true },
				-- css = { "prettierd", "prettier", stop_after_first = true },
				-- scss = { "prettierd", "prettier", stop_after_first = true },
				-- less = { "prettierd", "prettier", stop_after_first = true },
				-- html = { "prettierd", "prettier", stop_after_first = true },
				-- json = { "prettierd", "prettier", stop_after_first = true },
				-- jsonc = { "prettierd", "prettier", stop_after_first = true },
				-- yaml = { "prettierd", "prettier", stop_after_first = true },
				-- markdown = { "prettierd", "prettier", stop_after_first = true },
				-- ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
				-- graphql = { "prettierd", "prettier", stop_after_first = true },
				-- handlebars = { "prettierd", "prettier", stop_after_first = true },
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
				"vtsls",
				"eslint-lsp",
				"bash-language-server",
				"beautysh",
				"css-lsp",
				"html-lsp",
				"json-lsp",
				"lua-language-server",
				"marksman",
				"prettierd",
				"stylua",
				"tailwindcss-language-server",
				"yaml-language-server",
			},
		},
	},
}
