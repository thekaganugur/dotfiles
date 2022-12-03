require("neodev").setup({})

local servers = {
	"lua-language-server",
	"stylua",

	"typescript-language-server",
	"html-lsp",
	"css-lsp",
	"eslint-lsp",
	"prettierd",
	"json-lsp",
}

require("mason").setup()
require("null-ls").setup()

require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers(require("user.lsp.handlers").lsp)
require("mason-null-ls").setup()
require("mason-null-ls").setup_handlers(require("user.lsp.handlers").null_ls)

require("mason-tool-installer").setup({ ensure_installed = servers })

vim.diagnostic.config(require("user.lsp.diagnostics"))
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, require("user.lsp.diagnostics").float)
vim.lsp.handlers["textDocument/signatureHelp"] =
	vim.lsp.with(vim.lsp.handlers.signature_help, require("user.lsp.diagnostics").float)
vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
	link = "DiagnosticInfo",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local function on_attach(client, bufnr)
			require("user.lsp.keymaps")(bufnr)

			if client.server_capabilities.colorProvider then
				require("document-color").buf_attach(bufnr)
			end
			if require("user.lsp.utils").get_format_allowed(client, bufnr) then
				require("lsp-format").on_attach(client)
			end
		end

		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		on_attach(client, bufnr)
	end,
})

require("fidget").setup({ sources = { ["null-ls"] = { ignore = true } } })
require("lsp-format").setup()
-- https://github.com/lukas-reineke/lsp-format.nvim#wq-will-not-format-when-not-using-sync
vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]])
