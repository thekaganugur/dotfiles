vim.keymap.set({ "n", "i" }, "<C-x><C-f>", function()
	require("fzf-lua").fzf_exec("rg --files", {
		winopts = { preview = { hidden = true } },
		complete = function(selected, _, line, col)
			if #selected == 0 then
				return
			end
			local ref = "@" .. selected[1] .. " "
			local after = #line > col and line:sub(col + 1) or ""
			return line:sub(1, col) .. ref .. after, col + #ref - 1
		end,
	})
end, { silent = true, desc = "Insert AI file reference" })

local function start_with_args(name, extra_args, id_suffix)
	local states = require("sidekick.cli.state").get({ name = name, attached = true })
	local state = states[1]
	if state and state.terminal then
		state.terminal:show()
		state.terminal:focus()
		return
	end

	local tool_config = require("sidekick.config").get_tool(name)
	local argv = { tool_config.cmd[1] }
	vim.list_extend(argv, extra_args)

	local tool = tool_config:clone({ cmd = argv })
	local session_api = require("sidekick.cli.session")
	session_api.setup()
	local session = session_api.attach(session_api.new({
		backend = "terminal",
		id = ("terminal: %s %s %s"):format(name, id_suffix, vim.fn.sha256(vim.fn.getcwd()):sub(1, 8)),
		tool = tool,
	}))
	session:focus()
end

local function resume(name)
	local args = require("sidekick.config").get_tool(name).resume
	if args then
		start_with_args(name, args, "resume")
	end
end

return {
	"folke/sidekick.nvim",
	dependencies = { "folke/snacks.nvim" },
	keys = {
		-- stylua: ignore start
		{ "<leader>a",  nil, desc = "AI" },

		-- tool toggles
		{ "<C-a>",      function() require("sidekick.cli").show({ focus = true }) end, desc = "AI", mode = { "n", "t", "x" } },
		{ "<leader>ac", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "Claude", mode = { "n", "t", "x" } },
		{ "<leader>ax", function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end, desc = "Codex", mode = { "n", "t", "x" } },

		-- send context (auto-routes to active tool, picker if ambiguous)
		{ "<leader>al", function() require("sidekick.cli").send({ msg = "{line}" }) end, desc = "Send current line" },
		{ "<leader>ab", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Send buffer" },
		{ "<leader>as", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = "v", desc = "Send reference" },
		{ "<leader>aS", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = "v", desc = "Send selection" },
		{ "<leader>ad", function() require("sidekick.cli").send({ msg = "{diagnostics}" }) end, desc = "Send file diagnostics" },
		{ "<leader>aD", function() require("sidekick.cli").send({ msg = "{diagnostics_all}" }) end, desc = "Send all diagnostics" },

		-- resume
		{ "<leader>ar", function() resume("claude") end, desc = "Claude: resume" },
		{ "<leader>aR", function() resume("codex") end, desc = "Codex: resume" },
		-- stylua: ignore end
	},
	config = function(_, opts)
		require("sidekick").setup(opts)
		require("sidekick.config").cli.tools = { claude = {}, codex = {} }
	end,
	opts = {
		nes = { enabled = false },
		cli = {
			win = {
				layout = "float",
				float = { width = 0.95, height = 0.9, border = "rounded" },
				keys = {
					hide = { "<C-a>", "hide", mode = "t", desc = "Hide" },
					hide_claude = { "<leader>ac", "hide", mode = "t", desc = "Hide" },
					hide_codex = { "<leader>ax", "hide", mode = "t", desc = "Hide" },
				},
			},
		},
	},
}
