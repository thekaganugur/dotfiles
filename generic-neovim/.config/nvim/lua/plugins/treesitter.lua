return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	lazy = false,
	branch = "main",
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
		{ "windwp/nvim-ts-autotag", opts = {} },
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			config = function()
				require("nvim-treesitter-textobjects").setup({
					select = {
						lookahead = true,
						selection_modes = {
							["@parameter.outer"] = "v",
							["@function.outer"] = "V",
						},
						include_surrounding_whitespace = false,
					},
				})

				vim.keymap.set({ "x", "o" }, "af", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "if", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ac", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ic", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "aC", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@call.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "iC", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@call.inner", "textobjects")
				end)
			end,
		},
	},
	opts = {
		install_dir = vim.fn.stdpath("data") .. "/site",
	},
	config = function(_, opts)
		local parsers = {
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
		}

		local ts = require("nvim-treesitter")
		ts.setup(opts)
		ts.install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[0][0].foldmethod = "expr"
			end,
		})

		-- vim.api.nvim_create_autocmd("LspAttach", {
		-- 	callback = function(args)
		-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- 		if client and client:supports_method("textDocument/foldingRange") then
		-- 			local win = vim.api.nvim_get_current_win()
		-- 			vim.wo[win][0].foldmethod = "expr"
		-- 			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		-- 		end
		-- 	end,
		-- })
	end,
}
