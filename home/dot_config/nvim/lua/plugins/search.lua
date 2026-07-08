return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		keys = {
			-- stylua: ignore start
			{ "<C-p>", function() require("fzf-lua").global() end, desc = "Find files" },
			{ "<C-g>", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
			{ "<leader>s*", function() require("fzf-lua").grep_cword() end, desc = "[S]earch [*] current word" },
			{ "<leader>sr", function() require("fzf-lua").oldfiles() end, desc = "[S]earch [R]ecently opened files" },
			{ "<leader>sb", function() require("fzf-lua").buffers() end, desc = "[S]earch [B]uffers" },
			{ "<leader>s/", function() require("fzf-lua").blines() end, desc = "[S]earch in current [/] buffer" },
			{ "<leader>sh", function() require("fzf-lua").help_tags() end, desc = "[S]earch [H]elp" },
			{ "<leader>sd", function() require("fzf-lua").diagnostics_document() end, desc = "[S]earch [D]iagnostics" },
			{ "<leader>s:", function() require("fzf-lua").command_history() end, desc = "[S]earch [:] Command History" },
			-- stylua: ignore end
		},
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {
			"fzf-vim",
			fzf_colors = true,
			defaults = { cwd_prompt = false },
			grep = {
				RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
				file_ignore_patterns = { "yarn%.lock$" },
			},
			global = { file_ignore_patterns = { "%.yarn/" } },
			keymap = { fzf = { ["ctrl-q"] = "select-all+accept" } }, -- use ctrl-q to select all items and convert to quickfix list
		},
		---@diagnostic enable: missing-fields
		config = function(_, opts)
			local fzf = require("fzf-lua")
			fzf.setup(opts)
			fzf.register_ui_select({ winopts = { height = 0.30, width = 0.70, backdrop = 80 } })
		end,
	},

	{
		"MagicDuck/grug-far.nvim", -- Search and replace across the project
		opts = { headerMaxWidth = 80 },
		cmd = "GrugFar",
		keys = { {
			"<leader>ss",
			function()
				require("grug-far").open()
			end,
			desc = "GrugFar",
		} },
	},

	{ "kevinhwang91/nvim-bqf", event = "VeryLazy", opts = { preview = { auto_preview = true } } }, -- Improve quickfix navigation and preview
	{ "TamaMcGlinn/quickfixdd", event = "VeryLazy" }, -- Let `dd` remove quickfix entries
	{ "kwkarlwang/bufjump.nvim", opts = { backward_key = "<M-o>", forward_key = "<M-ı>" } }, -- Jump through buffer history
}
