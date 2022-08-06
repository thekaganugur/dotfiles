-- Fixes Autocomment
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	callback = function()
		vim.cmd("set formatoptions-=cro")
	end,
})

-- Highlight Yanked Text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto resize buffer when window resize
vim.api.nvim_create_autocmd({ "VimResized " }, {
	callback = function()
		vim.cmd("autocmd VimResized * wincmd =")
	end,
})
