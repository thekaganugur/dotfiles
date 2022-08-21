local function on_attach(client, bufnr)
	require("user.lsp.keymaps")(bufnr)
	if client.server_capabilities.colorProvider then
		require("document-color").buf_attach(bufnr)
	end
end
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local opts = {
	on_attach = on_attach,
	capabilities = capabilities,
}

return {
	function(server_name)
		require("lspconfig")[server_name].setup(opts)
	end,
	["tsserver"] = function()
		require("lspconfig").tsserver.setup(vim.tbl_extend("force", opts, {
			on_attach = function(client, bufnr)
				client.resolved_capabilities.document_formatting = false
				on_attach(client, bufnr)
			end,
			root_dir = vim.loop.cwd,
		}))
	end,
	["sumneko_lua"] = function()
		require("lspconfig").sumneko_lua.setup(vim.tbl_extend("force", opts, {
			on_attach = function(client, bufnr)
				client.resolved_capabilities.document_formatting = false
				vim.api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()" })
				on_attach(client, bufnr)
			end,
			settings = require("lua-dev").setup().settings,
		}))
	end,
	["eslint"] = function()
		require("lspconfig").eslint.setup(vim.tbl_extend("force", opts, {
			on_attach = function(client, bufnr)
				-- client.resolved_capabilities.document_formatting = true
				vim.api.nvim_create_autocmd("BufWritePre", { command = "EslintFixAll" })
				on_attach(client, bufnr)
			end,
		}))
	end,
}
