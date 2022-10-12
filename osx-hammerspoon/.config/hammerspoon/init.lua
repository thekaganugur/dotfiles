hs.loadSpoon("SpoonInstall")

hs.window.animationDuration = 0

hyper = { "cmd", "alt", "ctrl" }
shift_hyper = { "cmd", "alt", "ctrl", "shift" }

spoon.SpoonInstall.repos.lunette = {
	url = "https://github.com/scottwhudson/Lunette",
	desc = "scottwhudson's lunette spoon repository",
	branch = "master",
}

----------------------------------------------------------------------------------------------------
-- configurations

hs.hotkey.bind(hyper, "0", hs.reload, hs.alert.show("Config loaded"))

local hyper_apps = {
	E = "Finder",
	B = "Google Chrome",
	T = "iTerm",
	M = "Mail",
	A = "Calendar",
	W = "WhatsApp",
	S = "Spotify",
	V = "Visual Studio Code",
}
local shift_hyper_apps = {
	B = "Safari",
	S = "Slack",
}
for key, app in pairs(hyper_apps) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end
for key, app in pairs(shift_hyper_apps) do
	hs.hotkey.bind(shift_hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

----------------------------------------------------------------------------------------------------
-- spoons

spoon.SpoonInstall:andUse("Lunette", {
	repo = "lunette",
	enable = true,
	hotkeys = {
		center = {
			{ hyper, "c" },
		},
		fullScreen = {
			{ hyper, "return" },
		},
		leftHalf = {
			{ hyper, "h" },
		},
		rightHalf = {
			{ hyper, "l" },
		},
		topHalf = {
			{ hyper, "k" },
		},
		bottomHalf = {
			{ hyper, "j" },
		},
		nextDisplay = {
			{ shift_hyper, "l" },
		},
		prevDisplay = {
			{ shift_hyper, "h" },
		},
		undo = {
			{ hyper, "delete" },
		},
		redo = {
			{ shift_hyper, "delete" },
		},
		enlarge = {
			{ shift_hyper, "k" },
		},
		shrink = {
			{ shift_hyper, "j" },
		},
	},
})
