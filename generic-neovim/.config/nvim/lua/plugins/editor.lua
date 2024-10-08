return {
	-- search/replace in multiple files
	-- {
	-- 	"nvim-pack/nvim-spectre",
	-- 	cmd = "Spectre",
	-- 	opts = { is_block_ui_break = true },
	--    -- stylua: ignore
	--    keys = {
	--      { "<leader>ss", function() require("spectre").open() end, desc = "Replace in files [S]pectre" },
	--    },
	-- },
	{
		"MagicDuck/grug-far.nvim",
		opts = { headerMaxWidth = 80 },
		cmd = "GrugFar",
		keys = {
			{
				"<leader>ss",
				function()
					local grug = require("grug-far")
					-- Launch with the current visual selection, searching only current file
					-- If a file is open in the buffer
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.grug_far({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},

	-- references
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPre", "BufNewFile" },
		opts = { filetypes_denylist = { "TelescopePrompt", "qf", "lir", "dirvish", "fugitive" } },
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},

	-- which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function(_, opts)
			vim.o.timeoutlen = 300
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>g", desc = "+[G]it" },
				{ "<leader>l", desc = "+[L]SP" },
				{ "<leader>s", desc = "+[S]earch" },
				{ "<leader>x", group = "diagnostics/quickfix" },
			})
		end,
	},

	-- git signs
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

        -- stylua: ignore start
        map("n", "<leader>gj", gs.next_hunk, "Next Hunk")
        map("n", "<leader>gk", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")
        map("n", "<leader>gd", gs.diffthis, "Diff This")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        map("n", "<leader>gq", gs.setqflist, "Git changes qf")
			end,
		},
	},

	{
		"andrewferrier/debugprint.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = { print_tag = "DEBUG", display_counter = false },
	},

	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},

	{ "kevinhwang91/nvim-bqf", event = "VeryLazy", opts = { preview = { auto_preview = true } } },

	{ "TamaMcGlinn/quickfixdd", event = "VeryLazy" },

	{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },

	{
		"kevinhwang91/nvim-ufo",
		event = "VeryLazy",
		dependencies = "kevinhwang91/promise-async",
		opts = {},
		init = function()
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
	},

	{ "tpope/vim-fugitive", event = "VeryLazy" },

	{
		"ruifm/gitlinker.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = "nvim-lua/plenary.nvim",
		opts = {},
	},

	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
}
