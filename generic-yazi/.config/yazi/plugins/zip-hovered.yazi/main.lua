local hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return nil
	end

	local path = tostring(h.url.path)
	return {
		name = h.name,
		path = path,
		zip = path .. ".zip",
	}
end)

return {
	entry = function()
		local file = hovered()
		if not file then
			return
		end

		local ok = ya.confirm({
			pos = { "center", w = 56, h = 8 },
			title = "Create archive?",
			body = file.name .. " -> " .. file.name .. ".zip",
		})

		if ok then
			if fs.cha(Url(file.zip)) then
				ya.notify({
					title = "Archive exists",
					content = file.name .. ".zip was not changed",
					timeout = 4,
					level = "warn",
				})
				return
			end

			ya.emit("shell", {
				"zip -r " .. ya.quote(file.zip) .. " " .. ya.quote(file.path),
				block = true,
			})
		end
	end,
}
