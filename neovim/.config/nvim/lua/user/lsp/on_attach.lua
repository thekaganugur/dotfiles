-- *****************************
-- https://github.com/MunifTanjim/dotfiles/blob/160f61e/private_dot_config/nvim/lua/config/lsp/formatting.lua
local function get_filter(client, bufnr)
	local denylist = {
		clangd = true,
		jsonls = true,
		tsserver = true,
		stylelint_lsp = true,
	}
	local denylist_by_filetype = {
		lua = {
			sumneko_lua = true,
		},
		markdown = {
			html = true,
		},
	}

	if denylist[client.name] then
		return false
	end

	local filetype = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
	local denylist_for_filetype = denylist_by_filetype[filetype]
	if not denylist_for_filetype then
		return true
	end

	return not denylist_for_filetype[client.name]
end
-- *****************************

local function on_attach(client, bufnr)
	require("user.lsp.keymaps")(bufnr)

	if client.server_capabilities.colorProvider then
		require("document-color").buf_attach(bufnr)
	end
	if get_filter(client, bufnr) then
		require("lsp-format").on_attach(client)
	end
end

return on_attach
