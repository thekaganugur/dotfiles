require("neodev").setup({})

require("mason").setup()
require("null-ls").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers").lsp)
require("mason-null-ls").setup()
require("mason-null-ls").setup_handlers(require("user.lsp.handlers").null_ls)
require("mason-tool-installer").setup({ ensure_installed = require("user.lsp.utils").servers })

require("user.lsp.ui").setup()
require("fidget").setup({ sources = { ["null-ls"] = { ignore = true } } })
require("ufo").setup()
require("lsp-format").setup()
require("user.lsp.on_attach")

vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]]) -- https://github.com/lukas-reineke/lsp-format.nvim#wq-will-not-format-when-not-using-sync
