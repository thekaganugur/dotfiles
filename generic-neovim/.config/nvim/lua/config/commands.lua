vim.api.nvim_create_user_command("RunCode", function()
	local file_type = vim.bo.filetype

	if file_type == "typescript" or file_type == "javascript" then
		vim.cmd("w !node --no-warnings")
	else
		print("Unsupported file type: " .. file_type)
		return
	end
end, {})
