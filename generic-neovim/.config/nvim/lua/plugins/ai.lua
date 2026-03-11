local toggle_key = "<C-,>"

return {
	"folke/sidekick.nvim",
	dependencies = { "folke/snacks.nvim" },
	keys = {
		{ "<leader>a", nil, desc = "AI/Sidekick" },
		{ "<leader>c", nil, desc = "AI/Codex" },
		{
			"<C-a>",
			function()
				require("sidekick.cli").toggle({ name = "codex", focus = true })
			end,
			mode = { "n", "t" },
			desc = "Codex: open interactive",
		},
		{
			"<leader>cf",
			function()
				require("sidekick.cli").focus("codex")
			end,
			desc = "Codex: focus",
		},
		{
			"<leader>cl",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{line}" })
			end,
			desc = "Codex: current line",
		},
		{
			"<leader>cb",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{file}" })
			end,
			desc = "Codex: current buffer",
		},
		{
			"<leader>cs",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{this}" })
			end,
			mode = "v",
			desc = "Codex: send reference",
		},
		{
			"<leader>cS",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{selection}" })
			end,
			mode = "v",
			desc = "Codex: send selection",
		},
		{
			"<leader>cd",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{diagnostics}" })
			end,
			desc = "Codex: send file diagnostics",
		},
		{
			"<leader>cD",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{diagnostics_all}" })
			end,
			desc = "Codex: send all diagnostics",
		},
		{
			"<leader>cr",
			function()
				require("sidekick.cli").show({ name = "codex", focus = true })
			end,
			desc = "Codex: resume",
		},
		{
			"<leader>aC",
			function()
				require("sidekick.cli").prompt({
					cb = function(_, text)
						if text then
							require("sidekick.cli").send({ name = "codex", text = text })
						end
					end,
				})
			end,
			desc = "Select prompt",
		},
		{
			"<leader>am",
			function()
				require("sidekick.cli").select()
			end,
			desc = "Select AI CLI",
		},
		{
			"<leader>ab",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{file}" })
			end,
			desc = "Send current buffer",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{selection}" })
			end,
			mode = "v",
			desc = "Send selection",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").send({ name = "codex", msg = "{file}" })
			end,
			desc = "Send file",
			ft = { "NvimTree", "neo-tree", "oil" },
		},
		{
			toggle_key,
			function()
				require("sidekick.cli").toggle({ name = "codex", focus = true })
			end,
			desc = "Sidekick",
			mode = { "n", "t", "x" },
		},
	},

	config = function(_, opts)
		require("sidekick").setup(opts)
		if not vim.g.sidekick_win_cursor_guard then
			vim.g.sidekick_win_cursor_guard = true
			local api = vim.api
			local orig = api.nvim_win_get_cursor
			-- Guard against sidekick timer calling into a closed window.
			api.nvim_win_get_cursor = function(win)
				if not win or not api.nvim_win_is_valid(win) then
					return { 1, 0 }
				end
				return orig(win)
			end
		end
	end,

	opts = {
		nes = {
			enabled = false,
		},
		cli = {
			win = {
				layout = "float",
				float = {
					width = 0.9,
					height = 0.9,
					border = "rounded",
				},
				keys = {
					hide_ctrl_comma = { toggle_key, "hide", mode = "t", desc = "Hide" },
				},
			},
		},
	},
}
