local function set_lsp_keymaps(bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	local telescope_builtin = require("telescope.builtin")

	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, bufopts)
	vim.keymap.set("n", "gt", telescope_builtin.lsp_type_definitions, bufopts)
	vim.keymap.set("n", "gi", telescope_builtin.lsp_implementations, bufopts)
	vim.keymap.set("n", "gr", telescope_builtin.lsp_references, bufopts)
	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "<leader>lf", vim.lsp.buf.formatting, bufopts)

	vim.keymap.set("n", "H", vim.diagnostic.open_float, bufopts)
	vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, bufopts)
	vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, bufopts)
	vim.keymap.set("n", "<leader>ld", telescope_builtin.diagnostics, bufopts)

	vim.keymap.set("n", "<leader>lo", telescope_builtin.lsp_document_symbols, bufopts)
end

return set_lsp_keymaps
