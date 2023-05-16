return {
	{
		"vifm/vifm.vim",
		cmd = "Vifm",
		init = function()
			vim.keymap.set("n", "<leader>-", "<cmd>Vifm<cr>", { desc = "Vifm" })
		end,
	},

	{
		"tamago324/lir.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "tamago324/lir-git-status.nvim" },
		keys = { { "-", "<Cmd>execute 'e ' .. expand('%:p:h')<CR>", "Open Lir" } },
		opts = function()
			local actions = require("lir.actions")
			local mark_actions = require("lir.mark.actions")
			local clipboard_actions = require("lir.clipboard.actions")
			return {
				show_hidden_files = true,
				devicons = { enable = true, highlight_dirname = true },
				mappings = {
					["<Enter>"] = actions.edit,
					["<C-s>"] = actions.split,
					["<C-v>"] = actions.vsplit,
					["<C-t>"] = actions.tabedit,

					["-"] = actions.up,
					["q"] = actions.quit,

					["A"] = actions.mkdir,
					["a"] = actions.touch,
					["cw"] = actions.rename,
					["D"] = actions.delete,

					["@"] = actions.cd,
					["."] = actions.toggle_show_hidden,

					["t"] = mark_actions.toggle_mark,
					["C"] = clipboard_actions.copy,
					["X"] = clipboard_actions.cut,
					["P"] = clipboard_actions.paste,
				},
			}
		end,
		config = function(_, opts)
			require("lir.git_status").setup()
			require("lir").setup(opts)
		end,
		init = function()
			-- Disable netrw
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},
}
