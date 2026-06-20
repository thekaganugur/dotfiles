-- Fixes Autocomment
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("DisableAutoComment", { clear = true }),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- https://github.com/fsouza/prettierd/issues/719#issuecomment-2078544807
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("RestartPrettierd", { clear = true }),
	pattern = "*prettier*",
	callback = function()
		vim.fn.system("prettierd restart")
	end,
})

-- Resize fugitive buffer to be smaller
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("FugitiveWindowSizing", { clear = true }),
	pattern = "fugitive",
	callback = function()
		local height = math.min(math.floor(vim.o.lines * 0.30), 10)
		vim.api.nvim_win_set_height(0, height)
		vim.cmd.normal({ "gg", bang = true })
	end,
})
