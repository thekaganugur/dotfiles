local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

return {
	function(server_name)
		require("lspconfig")[server_name].setup({ capabilities = capabilities })
	end,

	["tsserver"] = function()
		require("lspconfig").tsserver.setup({
			capabilities = capabilities,
			root_dir = vim.loop.cwd,
		})
	end,
	["eslint"] = function()
		require("lspconfig").eslint.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})
	end,
}
