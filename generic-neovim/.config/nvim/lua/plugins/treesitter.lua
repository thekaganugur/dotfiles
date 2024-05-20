return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
		{ "windwp/nvim-ts-autotag", opts = {} },

		"nvim-treesitter/nvim-treesitter-textobjects",
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
