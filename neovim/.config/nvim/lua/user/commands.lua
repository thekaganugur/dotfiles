vim.api.nvim_command([[ command Format execute "lua vim.lsp.buf.formatting()" ]])
vim.api.nvim_command(
	[[ command FormatAuto execute 'lua vim.api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()" })' ]]
)
