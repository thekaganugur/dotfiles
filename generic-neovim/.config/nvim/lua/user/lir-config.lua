local actions = require("lir.actions")
local mark_actions = require("lir.mark.actions")
local clipboard_actions = require("lir.clipboard.actions")

require("lir").setup({
	show_hidden_files = true,
	devicons = {
		enable = true,
	},
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
})

-- dirvish like binding '-' opens lir
vim.keymap.set("n", "-", [[<Cmd>execute 'e ' .. expand('%:p:h')<CR>]], { desc = "Open Lir" })
