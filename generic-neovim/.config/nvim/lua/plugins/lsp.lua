return {
	{
		"neovim/nvim-lspconfig",
		init = function()
			require("utils").on_attach(function(_client, buffer)
				vim.diagnostic.config({
					float = { border = "rounded" },
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = "󰅚 ",
							[vim.diagnostic.severity.WARN] = "󰀪 ",
							[vim.diagnostic.severity.HINT] = "󰌶 ",
							[vim.diagnostic.severity.INFO] = " ",
						},
					},
				})

				local hover = vim.lsp.buf.hover
				vim.lsp.buf.hover = function()
					return hover({ border = "rounded" })
				end

				local signature_help = vim.lsp.buf.signature_help
				vim.lsp.buf.signature_help = function()
					return signature_help({ border = "rounded" })
				end

				-- LSP Keymaps
				local fzf = require("fzf-lua")
				local function get_opts(desc)
					return { noremap = true, silent = true, buffer = buffer, desc = desc }
				end

				vim.keymap.set("n", "gd", fzf.lsp_definitions, get_opts("[G]o Definition"))
				vim.keymap.set("n", "gt", fzf.lsp_typedefs, get_opts("[G]o Type"))
				vim.keymap.set("n", "gi", fzf.lsp_implementations, get_opts("[G]o Implementations"))
				vim.keymap.set("n", "gr", fzf.lsp_references, get_opts("[G]o References"))
				vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, get_opts("[L]sp [R]ename"))
				vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, get_opts("[L]sp [S]ignature"))
				vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, get_opts("[L]sp [A]ction"))

				vim.keymap.set("n", "H", vim.diagnostic.open_float, get_opts("[L]sp [H]over Diagnostic"))
				vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, get_opts("[L]sp [J]Next Diagnostic"))
				vim.keymap.set("n", "<leader>lJ", function()
					vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
				end, get_opts("[L]sp [J]Next Diagnostic Error"))
				vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, get_opts("[L]sp [K]Prev Diagnostic"))
				vim.keymap.set("n", "<leader>lK", function()
					vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
				end, get_opts("[L]sp [K]Prev Diagnostic Error"))
				vim.keymap.set(
					"n",
					"<leader>lq",
					vim.diagnostic.setloclist,
					{ noremap = true, silent = true, buffer = buffer }
				)
				vim.keymap.set("n", "<leader>ld", fzf.diagnostics_document, get_opts("[L]sp [D]iagnostic"))

				vim.keymap.set("n", "<leader>lo", fzf.lsp_document_symbols, get_opts("[L]sp [O]utline"))
				vim.keymap.set("n", "<leader>lw", fzf.lsp_workspace_symbols, get_opts("[L]sp [W]orkspace Outline"))
			end)
		end,
	},

	{ "folke/lazydev.nvim", ft = "lua", opts = { library = { "lazy.nvim" } } },

	{ "mason-org/mason.nvim", opts = {} },
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
		opts = {},
	},

	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				lsp_fallback = true, -- Attempt LSP formatting if no formatters are available
			},
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
