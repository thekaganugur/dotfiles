-- Fixes Autocomment
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
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
	pattern = "fugitive",
	callback = function()
		local height = math.min(math.floor(vim.o.lines * 0.40), 12)
		vim.cmd("resize " .. height)
		vim.cmd("normal! gg")
	end,
})
