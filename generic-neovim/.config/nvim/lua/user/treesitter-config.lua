require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },

	autotag = { enable = true },
	autopairs = { enable = true },
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
})
