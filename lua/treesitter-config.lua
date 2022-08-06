require("nvim-treesitter.configs").setup({
	ensure_installed = "all",
	ignore_install = { "phpdoc" },
	highlight = { enable = true },
	indent = { enable = true },
	autotag = { enable = true },
	autopairs = { enable = true },
	endwise = { enable = true },
	context_commentstring = { enable = true, enable_autocmd = false },
})
