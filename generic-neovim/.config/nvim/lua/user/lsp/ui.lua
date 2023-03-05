local M = {}

local function get_diagnostic_signs()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}
	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end
	return signs
end
local float = {
	focusable = true,
	style = "minimal",
	border = "rounded",
	source = "always",
	header = "",
	prefix = "",
}
local diagnostic = {
	virtual_text = false,
	signs = {
		active = get_diagnostic_signs(),
	},
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = float,
}
local hover = vim.lsp.with(vim.lsp.handlers.hover, float)
local signatureHelp = vim.lsp.with(vim.lsp.handlers.signature_help, float)

M.setup = function()
	vim.diagnostic.config(diagnostic)
	vim.lsp.handlers["textDocument/hover"] = hover
	vim.lsp.handlers["textDocument/signatureHelp"] = signatureHelp
	vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
		link = "DiagnosticInfo",
	})
end

return M
