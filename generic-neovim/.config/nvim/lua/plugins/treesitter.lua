return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/playground",
		"nvim-treesitter/nvim-treesitter-textobjects",
		"JoosepAlviste/nvim-ts-context-commentstring",
		"windwp/nvim-ts-autotag",
		"RRethy/nvim-treesitter-endwise",
	},
	opts = {
		ensure_installed = {
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"query",
			"regex",
			"typescript",
			"tsx",
			"vim",
		},
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		autotag = { enable = true },
		endwise = { enable = true },
		context_commentstring = { enable = true, enable_autocmd = false },
		textobjects = {
			select = {
				enable = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					["aC"] = "@call.outer",
					["iC"] = "@call.inner",
				},
			},
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
