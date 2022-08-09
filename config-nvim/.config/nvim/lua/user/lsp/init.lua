require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers"))
require("user.lsp.diagnostics")

require("null-ls").setup({
	sources = {
		require("null-ls").builtins.formatting.prettierd,
		require("null-ls").builtins.formatting.stylua,
	},
})

require("fidget").setup({
	sources = { ["null-ls"] = { ignore = true } },
})
