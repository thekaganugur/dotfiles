local telescope_builtin = require("telescope.builtin")

local function set_lsp_keymaps(bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	local function get_opts(desc)
		return { noremap = true, silent = true, buffer = bufnr, desc = desc }
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
	vim.keymap.set("n", "<leader>lf", vim.lsp.buf.formatting, get_opts("[L]sp [F]ormat"))

	vim.keymap.set("n", "H", vim.diagnostic.open_float, get_opts("[L]sp [H]over Diagnostic"))
	vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, get_opts("[L]sp [J]Next Diagnostic"))
	vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, get_opts("[L]sp [K]Prev Diagnostic"))
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

return set_lsp_keymaps
