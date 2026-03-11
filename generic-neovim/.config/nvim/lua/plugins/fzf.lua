return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		"fzf-vim",
		fzf_colors = true,
		defaults = {
			cwd_prompt = false,
		},
		grep = { file_ignore_patterns = { "yarn%.lock$" } },
		global = { file_ignore_patterns = { "%.yarn/" } },
		keymap = {
			fzf = { ["ctrl-q"] = "select-all+accept" }, -- use cltr-q to select all items and convert to quickfix list
		},
	},
	init = function()
		local fzf = require("fzf-lua")
		fzf.register_ui_select({ winopts = { height = 0.30, width = 0.70, backdrop = 80 } })

		vim.keymap.set("n", "<C-p>", fzf.global, { desc = "Find files" })
		vim.keymap.set("n", "<C-g>", fzf.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>*", fzf.grep_cword, { desc = "[*] Find current word" })
		vim.keymap.set("n", "<leader>sr", fzf.oldfiles, { desc = "[S]earch [R]ecently opened files" })
		vim.keymap.set("n", "<leader>sb", fzf.buffers, { desc = "[S]earch [B]uffers" })
		vim.keymap.set("n", "<leader>s/", fzf.blines, { desc = "[S]earch in current [/] buffer" })
		vim.keymap.set("n", "<leader>sh", fzf.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sd", fzf.diagnostics_document, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>s:", fzf.command_history, { desc = "[S]earch [:] Command History" })
	end,
}
