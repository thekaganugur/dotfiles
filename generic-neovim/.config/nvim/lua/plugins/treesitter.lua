return {
	{
		"nvim-treesitter/nvim-treesitter", -- Provide parser-based highlighting, folds, and indentation
		lazy = false,
		build = ":TSUpdate",
		branch = "main",
		config = function()
			require("nvim-treesitter").install({
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
				"latex",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local has_parser = pcall(vim.treesitter.start, args.buf)
					if not has_parser then
						return
					end
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[0][0].foldmethod = "expr"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects", -- Add syntax-aware text objects
		branch = "main",
		config = function()
		      -- stylua: ignore start
				require("nvim-treesitter-textobjects").setup({
					select = { lookahead = true, selection_modes = { ["@parameter.outer"] = "v", ["@function.outer"] = "V" }, include_surrounding_whitespace = false },
				})
				vim.keymap.set({ "x", "o" }, "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end, { desc = "Select outer function" })
				vim.keymap.set({ "x", "o" }, "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end, { desc = "Select inner function" })
				vim.keymap.set({ "x", "o" }, "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects") end, { desc = "Select outer class" })
				vim.keymap.set({ "x", "o" }, "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects") end, { desc = "Select inner class" })
				vim.keymap.set({ "x", "o" }, "aC", function() require("nvim-treesitter-textobjects.select").select_textobject("@call.outer", "textobjects") end, { desc = "Select outer call" })
				vim.keymap.set({ "x", "o" }, "iC", function() require("nvim-treesitter-textobjects.select").select_textobject("@call.inner", "textobjects") end, { desc = "Select inner call" })
			-- stylua: ignore end
		end,
	},
}
