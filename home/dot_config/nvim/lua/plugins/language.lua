return {
	{
		"neovim/nvim-lspconfig", -- Configure language servers and LSP keymaps
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local fzf = require("fzf-lua")

					-- keep Neovim built-ins:
					-- grn    rename
					-- gra    code action
					vim.keymap.set("n", "gd", fzf.lsp_definitions, { buffer = args.buf, desc = "Goto Definition" })
					vim.keymap.set("n", "grr", fzf.lsp_references, { buffer = args.buf, desc = "Goto References" })
					vim.keymap.set(
						"n",
						"gri",
						fzf.lsp_implementations,
						{ buffer = args.buf, desc = "Goto Implementations" }
					)
					vim.keymap.set("n", "grt", fzf.lsp_typedefs, { buffer = args.buf, desc = "Goto Type Definition" })
					vim.keymap.set("n", "gO", fzf.lsp_document_symbols, { buffer = args.buf, desc = "Outline" })
					vim.keymap.set(
						"n",
						"gK",
						vim.lsp.buf.signature_help,
						{ buffer = args.buf, desc = "Signature Help" }
					)
				end,
			})
		end,
	},

	{ "folke/lazydev.nvim", ft = "lua", opts = { library = { "lazy.nvim" } } }, -- Improve Lua tooling for Neovim config files
	{ "mason-org/mason.nvim", opts = {} }, -- Install and manage external editor tools
	{
		"mason-org/mason-lspconfig.nvim", -- Connect Mason packages with LSP server configs
		dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
		opts = {},
	},
	{ "j-hui/fidget.nvim", opts = {} }, -- Show LSP progress and notifications
	{ "dmmulroy/tsc.nvim", config = true, cmd = "TSC" }, -- Run project-wide TypeScript checks
	{ "typed-rocks/ts-worksheet-neovim", opts = {} }, -- Show live TypeScript results inline

	{
		"stevearc/conform.nvim", -- Format buffers with external formatters
		opts = {
			format_on_save = { lsp_fallback = true }, -- Attempt LSP formatting if no formatters are available
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "beautysh" },
				zsh = { "beautysh" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				vue = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				less = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},
}
