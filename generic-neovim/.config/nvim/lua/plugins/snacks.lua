return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		lazygit = {
			enabled = true,
			config = {
				os = {
					edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote {{filename}})',
					editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote +{{line}} {{filename}})',
					editAtLineAndWait = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote +{{line}} {{filename}})',
				},
			},
		},
		input = { enabled = true },
		gitbrowse = { enabled = true },
		words = { enabled = true },
		notifier = { enabled = true },
		terminal = { enabled = true },
	},
	keys = {
		-- stylua: ignore start
		{ "<leader>gl", function() Snacks.lazygit() end, desc = "LazyGit" },
		{ "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Open Browser" },
		{ "<A-n>", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
		{ "<A-p>", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
		-- stylua: ignore end
	},
}
