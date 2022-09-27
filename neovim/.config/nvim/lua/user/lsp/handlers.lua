-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local bufnr = args.buf
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
-- 		on_attach(client, bufnr)
-- 	end,
-- })

local on_attach = require("user.lsp.on_attach")
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

return {
	function(server_name)
		require("lspconfig")[server_name].setup({ capabilities = capabilities, on_attach = on_attach })
	end,
	["tsserver"] = function()
		require("lspconfig").tsserver.setup({
			capabilities = capabilities,
			root_dir = vim.loop.cwd,
			on_attach = on_attach,
		})
	end,
	["sumneko_lua"] = function()
		require("lspconfig").sumneko_lua.setup({
			capabilities = capabilities,
			settings = require("lua-dev").setup().settings,
			on_attach = on_attach,
		})
	end,
	["eslint"] = function()
		require("lspconfig").eslint.setup({
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				client.server_capabilities.document_formatting = true
			end,
		})
	end,
}
