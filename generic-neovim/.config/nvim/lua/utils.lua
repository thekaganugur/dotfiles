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

M.is_wsl = (function()
	local output = vim.fn.systemlist("uname -r")
	return not not string.find(output[1] or "", "WSL")
end)()

M.is_mac = vim.fn.has("macunix") == 1

M.is_linux = not M.is_wsl and not M.is_mac

return M
