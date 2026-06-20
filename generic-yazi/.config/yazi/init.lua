function Linemode:mtime_dmy()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		return ""
	end

	if os.date("%Y", time) == os.date("%Y") then
		return os.date("%d/%m %H:%M", time)
	end

	return os.date("%d/%m %Y", time)
end
