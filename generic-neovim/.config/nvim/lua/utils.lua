local M = {}

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach(client, buffer)
		end,
	})
end

-- https://github.com/MunifTanjim/dotfiles/blob/160f61e/private_dot_config/nvim/lua/config/lsp/formatting.lua
M.can_format_with_client = function(client, buffer)
	local formatting_deny_list = require("config.lsp").formatting_deny_list
	local is_denied_by_client = formatting_deny_list.clients[client.name] or false
	local is_denied_by_filetype = (formatting_deny_list.filetypes[vim.bo[buffer or 0].filetype] or {})[client.name]
		or false
	local is_client_denied = is_denied_by_client or is_denied_by_filetype
	return not is_client_denied
end

M.has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

M.filter_servers = function(servers, exclude)
	local filtered_servers = {}
	for _, server in ipairs(servers) do
		if not vim.tbl_contains(exclude, server) then
			table.insert(filtered_servers, server)
		end
	end
	return filtered_servers
end

return M
