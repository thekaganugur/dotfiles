local M = {}

M.lsp_handlers = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}
	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	-- LSP handlers configuration
	local config = {
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
		diagnostic = {
			virtual_text = false,
			-- virtual_text = { severity = vim.diagnostic.severity.ERROR },
			signs = {
				active = signs,
			},
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		},
	}
	vim.diagnostic.config(config.diagnostic)
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
end

M.lsp_keymappings = function(buffer)
	local telescope_builtin = require("telescope.builtin")
	local bufopts = { noremap = true, silent = true, buffer = buffer }
	local function get_opts(desc)
		return { noremap = true, silent = true, buffer = buffer, desc = desc }
	end

	vim.keymap.set("n", "K", vim.lsp.buf.hover, get_opts("Hover"))
	vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, get_opts("[G]o Definition"))
	vim.keymap.set("n", "gt", telescope_builtin.lsp_type_definitions, get_opts("[G]o Type"))
	vim.keymap.set("n", "gi", telescope_builtin.lsp_implementations, get_opts("[G]o Implementations"))
	vim.keymap.set("n", "gr", telescope_builtin.lsp_references, get_opts("[G]o References"))
	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, get_opts("[L]sp [R]ename"))
	vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, get_opts("[L]sp [S]ignature"))
	vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, get_opts("[L]sp [S]ignature"))
	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, get_opts("[L]sp [A]ction"))
	-- vim.keymap.set("n", "<leader>lf", vim.lsp.buf.formatting, get_opts("[L]sp [F]ormat"))

	vim.keymap.set("n", "H", vim.diagnostic.open_float, get_opts("[L]sp [H]over Diagnostic"))
	vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, get_opts("[L]sp [J]Next Diagnostic"))
	vim.keymap.set("n", "<leader>lJ", function()
		vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	end, get_opts("[L]sp [J]Next Diagnostic Error"))
	vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, get_opts("[L]sp [K]Prev Diagnostic"))
	vim.keymap.set("n", "<leader>lK", function()
		vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	end, get_opts("[L]sp [K]Prev Diagnostic Error"))
	vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, bufopts)
	vim.keymap.set("n", "<leader>ld", telescope_builtin.diagnostics, get_opts("[L]sp [D]iagnostic"))

	vim.keymap.set("n", "<leader>lo", telescope_builtin.lsp_document_symbols, get_opts("[L]sp [O]utline"))
	vim.keymap.set(
		"n",
		"<leader>lw",
		telescope_builtin.lsp_dynamic_workspace_symbols,
		get_opts("[L]sp [W]orkspace Outline")
	)
end

M.lsp_formatting = function(client, buffer)
	if require("utils").can_format_with_client(client, buffer) then
		require("lsp-format").on_attach(client)
	end
end

M.formatting_deny_list = {
	clients = {
		tsserver = true,
		jsonls = true,
		lua_ls = true,
	},
	filetypes = {
		markdown = {
			html = true,
		},
	},
}

return M
