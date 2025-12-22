return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		zen = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		gitbrowse = { enabled = true },
		words = { enabled = true },
		notifier = { enabled = true },
		image = { enabled = false },
		terminal = { enabled = true },
		styles = { zen = { keys = { q = "close" } } },
	},
	keys = {
    -- stylua: ignore start
		{ "<leader>gl", function() Snacks.lazygit() end, desc = "LazyGit" },
		{ "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Open Browser" },
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
		{ "<A-n>", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
		{ "<A-p>", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
		-- stylua: ignore end
	},
}
