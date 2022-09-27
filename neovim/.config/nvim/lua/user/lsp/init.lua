require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers"))
require("fidget").setup({
	sources = { ["null-ls"] = { ignore = true } },
})
require("user.lsp.diagnostics")
require("user.lsp.null-ls")

require("lsp-format").setup()
vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]]) -- https://github.com/lukas-reineke/lsp-format.nvim#wq-will-not-format-when-not-using-sync

-- TODO: Manually installing servers is risky. Make a list and automate it.
