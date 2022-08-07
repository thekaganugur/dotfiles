local function lsp_keymaps(bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	local telescope_builtin = require("telescope.builtin")

	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, bufopts)
	vim.keymap.set("n", "gt", telescope_builtin.lsp_type_definitions, bufopts)
	vim.keymap.set("n", "gi", telescope_builtin.lsp_implementations, bufopts)
	vim.keymap.set("n", "gr", telescope_builtin.lsp_references, bufopts)
	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "<leader>lf", vim.lsp.buf.formatting, bufopts)

	vim.keymap.set("n", "H", vim.diagnostic.open_float, bufopts)
	vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, bufopts)
	vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, bufopts)
	vim.keymap.set("n", "<leader>ld", telescope_builtin.diagnostics, bufopts)

	vim.keymap.set("n", "<leader>lo", telescope_builtin.lsp_document_symbols, bufopts)
end

local function on_attach(client, bufnr)
	require("illuminate").on_attach(client)
	lsp_keymaps(bufnr)
end
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

return {
	function(server_name)
		require("lspconfig")[server_name].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end,
	["tsserver"] = function()
		require("lspconfig").tsserver.setup({
			on_attach = function(client, bufnr)
				client.resolved_capabilities.document_formatting = false
				on_attach(client, bufnr)
			end,
			capabilities = capabilities,
			root_dir = vim.loop.cwd,
		})
	end,
	["sumneko_lua"] = function()
		require("lspconfig").sumneko_lua.setup({
			on_attach = function(client, bufnr)
				client.resolved_capabilities.document_formatting = false
				vim.api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()" })
				require("lsp-format").on_attach(client)
				on_attach(client, bufnr)
			end,
			settings = require("lua-dev").setup().settings,
			capabilities = capabilities,
		})
	end,
	["eslint"] = function()
		require("lspconfig").eslint.setup({
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", { command = "EslintFixAll" })
				require("lsp-format").on_attach(client)
				on_attach(client, bufnr)
			end,
			capabilities = capabilities,
		})
	end,

	-- ["null-ls"] = require("null-ls").setup({
	-- 	on_attach = function(client, bufnr)
	-- 		print("fooooooo")
	-- 		if client.supports_method("textDocument/formatting") then
	-- 			print("fooooooo")
	-- 			require("lsp-format").on_attach(client)
	-- 		end
	-- 	end,
	-- }),
}
