require("neodev").setup({})

require("mason").setup()
require("null-ls").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers").lsp)
require("mason-null-ls").setup()
require("mason-null-ls").setup_handlers(require("user.lsp.handlers").null_ls)
require("mason-tool-installer").setup({ ensure_installed = require("user.lsp.utils").servers })

vim.diagnostic.config(require("user.lsp.diagnostics"))
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, require("user.lsp.diagnostics").float)
vim.lsp.handlers["textDocument/signatureHelp"] =
	vim.lsp.with(vim.lsp.handlers.signature_help, require("user.lsp.diagnostics").float)
vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
	link = "DiagnosticInfo",
})

require("fidget").setup({ sources = { ["null-ls"] = { ignore = true } } })
require("ufo").setup({})
require("lsp-format").setup()
vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]]) -- https://github.com/lukas-reineke/lsp-format.nvim#wq-will-not-format-when-not-using-sync

require("user.lsp.on_attach")
