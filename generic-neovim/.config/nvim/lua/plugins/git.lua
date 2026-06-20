return {
	{
		"lewis6991/gitsigns.nvim", -- Show and act on Git hunks in buffers
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

        -- stylua: ignore start
				-- Navigation
				map("n", "]c", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next Hunk")
				map("n", "[c", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev Hunk")

				-- Hunk actions
				map("n", "<leader>hs", gs.stage_hunk, "Git Hunk Stage")
				map("n", "<leader>hr", gs.reset_hunk, "Git Hunk Reset")
				map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git Hunk Stage")
				map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git Hunk Reset")
				map("n", "<leader>hS", gs.stage_buffer, "Git Hunk Stage Buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Git Hunk Reset Buffer")
				-- Preview / diff
				map("n", "<leader>hp", gs.preview_hunk, "Git Hunk Preview Popup")
				map("n", "<leader>hi", gs.preview_hunk_inline, "Git Hunk Preview Inline")
				map("n", "<leader>hd", gs.diffthis, "Git Hunk Diff")
				map("n", "<leader>hD", function() gs.diffthis("~") end, "Git Hunk Diff ~")

				-- Blame
				map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Git Hunk Blame Line")
				map("n", "<leader>hB", gs.blame, "Git Hunk Blame Buffer")

				-- Lists
				map("n", "<leader>hq", gs.setqflist, "Git Hunks Quickfix")
				map("n", "<leader>hQ", function() gs.setqflist("all") end, "Git Hunks Quickfix All")
				map("n", "<leader>hl", gs.setloclist, "Git Hunks Loclist")

				-- Toggles
				map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle Git Blame Line")
				map("n", "<leader>htw", gs.toggle_word_diff, "Toggle Git Word Diff")
				map("n", "<leader>htg", gs.toggle_signs, "Toggle Git Signs")

				-- Text object
				map({ "o", "x" }, "ih", gs.select_hunk, "Git Hunk Text Object")
				-- stylua: ignore end
			end,
		},
	},
	{ "tpope/vim-fugitive", event = "VeryLazy" }, -- Add Git commands and buffer integration
}
