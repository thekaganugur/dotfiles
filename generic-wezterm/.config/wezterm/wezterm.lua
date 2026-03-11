local wezterm = require("wezterm")
local act = wezterm.action

local config = {
	check_for_updates = false,

	font = wezterm.font("Iosevka NFM"),
	font_size = 18.0,
	line_height = 1.1,
	color_scheme = "Everforest Light (Hard)",
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },

	keys = {
		-- Clears the scrollback and viewport, and then sends CTRL-L to ask the
		-- shell to redraw its prompt
		{
			key = "k",
			mods = "CMD",
			action = act.Multiple({
				act.ClearScrollback("ScrollbackAndViewport"),
				act.SendKey({ key = "L", mods = "CTRL" }),
			}),
		},
		{
			key = "raw:51",
			mods = "ALT",
			action = wezterm.action.SendString("\x17"),
		},
		{
			key = "raw:51",
			mods = "CTRL",
			action = wezterm.action.SendString("\x17"),
		},
		-- Fix Ctrl+, key binding for Neovim
		{
			key = ",",
			mods = "CTRL",
			action = act.SendKey({ key = ",", mods = "CTRL" }),
		},

		-- brackets
		{ key = "ğ", action = act.SendString("[") },
		{ key = "ü", action = act.SendString("]") },

		-- braces on the shifted variants
		{ key = "Ğ", action = act.SendString("{") },
		{ key = "Ü", action = act.SendString("}") },
	},
}

return config
