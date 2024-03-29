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
			"vim",
			"markdown",
			"markdown_inline",
			"lua",
			"bash",
			"regex",
			"html",
			"javascript",
			"json",
			"query",
			"typescript",
			"tsx",
		},
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		autotag = { enable = true, enable_close_on_slash = false, enable_rename = true },
		endwise = { enable = true },
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
