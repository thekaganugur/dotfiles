local capabilities = require("cmp_nvim_lsp").default_capabilities()
local M = {}

M.lsp = {
	function(server_name)
		require("lspconfig")[server_name].setup({ capabilities = capabilities })
	end,
	tsserver = function()
		require("lspconfig").tsserver.setup({
			capabilities = capabilities,
			root_dir = vim.loop.cwd,
			init_options = {
				plugins = {
					{
						name = "typescript-lit-html-plugin",
						location = vim.env.NODE_LIB,
					},
				},
			},
		})
	end,
	eslint = function()
		require("lspconfig").eslint.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})
	end,
}

M.null_ls = {
	function(server_name)
		print("-- There is not configured server for null-ls --")
		print(server_name)
	end,
	stylua = function()
		require("null-ls").register(require("null-ls").builtins.formatting.stylua)
	end,
	prettierd = function()
		require("null-ls").register(require("null-ls").builtins.formatting.prettierd)
	end,
}

return M
