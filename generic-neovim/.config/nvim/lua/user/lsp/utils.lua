local M = {}

-- https://github.com/MunifTanjim/dotfiles/blob/160f61e/private_dot_config/nvim/lua/config/lsp/formatting.lua
M.get_format_allowed = function(client, bufnr)
	local denylist = {
		tsserver = true,
		jsonls = true,
		stylelint_lsp = true,
		lua_ls = true,
	}
	if denylist[client.name] then
		return false
	end

	local denylist_by_filetype = {
		markdown = {
			html = true,
		},
	}
	local filetype = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
	local denylist_for_filetype = denylist_by_filetype[filetype]
	if not denylist_for_filetype then
		return true
	end
	return not denylist_for_filetype[client.name]
end

M.servers = {
	"lua-language-server",
	"stylua",

	"typescript-language-server",
	"html-lsp",
	"css-lsp",
	"eslint-lsp",
	"prettierd",
	"json-lsp",
}

return M
