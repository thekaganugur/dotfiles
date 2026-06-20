vim.diagnostic.config({
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
	underline = { severity = { min = vim.diagnostic.severity.INFO } },
})

vim.keymap.set("n", "gh", vim.diagnostic.open_float, { desc = "Hover Diagnostics" })

vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev Error" })

vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics Loclist" })
vim.keymap.set("n", "<leader>dQ", vim.diagnostic.setqflist, { desc = "Diagnostics Quickfix" })
