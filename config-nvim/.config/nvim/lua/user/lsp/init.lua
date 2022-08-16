require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers"))
require("fidget").setup({
	sources = { ["null-ls"] = { ignore = true } },
})
require("user.lsp.diagnostics")
require("user.lsp.null-ls")
